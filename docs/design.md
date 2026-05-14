# 乒乓语音计分器 — 设计文档

## 产品定位

运行在华为平板上的乒乓球比赛计分工具。核心场景：打乒乓球时，双方通过语音或手动操作给比赛计分，平板大屏清晰显示实时比分。

## 核心规则

### 计分规则

- 11 分制，任一方先到 11 分且领先 >= 2 分即赢得本局
- 10:10 平手后，需连得 2 分才赢（即 12:10、13:11……）
- 无上限分差要求，只要领先 2 分即判赢

### 换场规则

| 场景 | 规则 |
|------|------|
| 常规局结束 | 双方交换场地，比分归零，开始下一局 |
| 决胜局（最后一局） | 任一方先到 5 分时交换场地，比分不重置，仅交换左右显示位置 |

### 赛制

- 3 局 2 胜（BO3）
- 5 局 3 胜（BO5）
- 7 局 4 胜（BO7）

## 状态模型

```
MatchState
├── config: MatchConfig            // 赛制配置
│   ├── bestOf: number             // 3 / 5 / 7
│   ├── playerLeftName: string     // 左侧选手名
│   └── playerRightName: string    // 右侧选手名
├── gamesLeft: number              // 左侧胜局数
├── gamesRight: number             // 右侧胜局数
├── pointsLeft: number             // 当前局左侧得分
├── pointsRight: number            // 当前局右侧得分
├── sidesSwapped: boolean          // 决胜局是否已换场
├── currentGame: number            // 当前第几局（从 1 开始）
├── isFinished: boolean            // 比赛是否结束
├── winner: PlayerSide | null      // 胜方
└── history: GameResult[]          // 每局结果
    ├── gameNumber: number
    ├── scoreLeft: number
    └── scoreRight: number

PlayerSide = 'left' | 'right'

// 换场逻辑：sidesSwapped 控制显示映射
// sidesSwapped = false → 左=playerLeft, 右=playerRight
// sidesSwapped = true  → 左=playerRight, 右=playerLeft
```

### 关键状态转换

```
scorePoint(side):
  1. 增加对应方分数
  2. 检查是否赢得本局
     - 任一方 >= 11 且领先 >= 2 → 赢局
  3. 赢局处理：
     a. 增加胜局数
     b. 记录本局结果到 history
     c. 检查是否赢得比赛（胜局数 >= ceil(bestOf/2)）
        - 是 → 比赛结束
        - 否 → 触发换场（常规局）或标记即将换场
  4. 决胜局特殊处理：
     a. 任一方先到 5 分且 !sidesSwapped → 换场
     b. sidesSwapped = true，比分保留

swapSides():
  1. 交换 sidesSwapped 标志
  2. 交换当前局分数（pointsLeft ↔ pointsRight）
  3. UI 自动反映新位置（因 sidesSwapped 影响显示映射）

undoLastPoint():
  1. 如果比赛已结束 → 恢复到最后一局
  2. 如果本局有分 → 减去最后加分
  3. 如果本局 0:0 且有历史 → 恢复上一局

newGame():
  在上一局结束后调用：
  1. pointsLeft = 0, pointsRight = 0
  2. currentGame++
  3. 常规局：sidesSwapped 保持上一局结束时状态
     决胜局开始时：sidesSwapped = false
```

## 页面结构

### 1. 计分板页面（主页，ScoreboardPage）

横屏全屏布局：

```
┌─────────────────────────────────────────────────┐
│  第3局  BO5         局分 2:1                     │
│                                                   │
│   ┌──────────────┐      ┌──────────────┐        │
│   │              │      │              │        │
│   │     11       │      │      9       │        │
│   │              │      │              │        │
│   │   张三       │      │    李四       │        │
│   └──────────────┘      └──────────────┘        │
│                                                   │
│     [−]  [我得分]          [对方得分]  [−]        │
│                                                   │
│  [撤销]        [交换场地]          [新比赛]        │
└─────────────────────────────────────────────────┘
```

交互：
- 点击"我得分"/"对方得分" → 加分（大按钮，方便快速点击）
- 点击 "−" → 减分（小按钮）
- "撤销" → 撤销最后操作
- "交换场地" → 手动触发换场（仅在决胜局 5 分前可用）
- 换场时弹出动画提示

### 2. 比赛设置页面（SetupPage）

- 选择赛制：BO3 / BO5 / BO7
- 输入选手姓名
- 选择发球方
- 开始比赛按钮

### 3. 比赛记录页面（HistoryPage）

- 历史比赛列表
- 每场比赛的详细比分
- 胜率统计

## 文件结构

```
entry/src/main/ets/
├── entryability/
│   └── EntryAbility.ets           // 应用入口 Ability
├── model/
│   ├── MatchConfig.ets            // 赛制配置模型
│   ├── ScoreState.ets             // 比分状态模型
│   └── MatchRecord.ets            // 比赛记录模型（持久化用）
├── viewmodel/
│   └── ScoreViewModel.ets         // 核心业务逻辑
├── view/
│   ├── ScoreboardPage.ets         // 计分板主页
│   ├── SetupPage.ets             // 比赛设置页
│   ├── HistoryPage.ets           // 比赛记录页
│   ├── ScoreDisplay.ets          // 比分大字显示组件
│   └── SwapSidesDialog.ets       // 换场提示弹窗
├── service/
│   └── MatchStorageService.ets    // SQLite 存储服务
└── common/
    └── Constants.ets              // 常量定义
```

## 技术决策

| 决策 | 选择 | 理由 |
|------|------|------|
| 状态管理 | V2 (@ObservedV2 + @Trace) | ArkUI 官方推荐，V1 已废弃 |
| 路由 | Navigation + NavPathStack | 官方推荐，@ohos.router 已废弃 |
| 架构 | MVVM | View / ViewModel / Model 分离 |
| 持久化 | SQLite (relationalStore) | 结构化比赛记录，查询灵活 |
| 屏幕方向 | 锁定横屏 | 计分板场景只需横屏 |
| 语音（Phase 2） | @kit.CoreSpeechKit | 系统级，支持离线 |

## 开发阶段

### Phase 1 — 基础计分器

- 横屏大字比分 UI
- 手动加减分
- 11 分制自动判局（10:10 后 +2 赢）
- 常规局结束换场
- 决胜局 5 分换场
- 换场视觉提示（动画/弹窗）
- 局分累计
- 赛制选择（BO3/BO5/BO7）
- 撤销操作

### Phase 2 — 语音识别集成

- 接入 @kit.CoreSpeechKit
- 语音指令集："我得分" / "对方得分" / "撤销" / "重置"
- TTS 播报当前比分
- 噪声环境误识别处理

### Phase 3 — 比赛管理与统计

- SQLite 持久化比赛记录
- 历史比赛列表
- 统计面板（胜率、场均得分）

### Phase 4 — 打磨

- 深色模式
- 得分动效
- 语音指令自定义
- 横竖屏自适应（如需要）
