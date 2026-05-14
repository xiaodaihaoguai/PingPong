import { MatchConfig, PlayerSide } from "../model/MatchConfig"
import { ScoreState, GamePhase, GameResult } from "../model/ScoreState"
import { SCORE_TO_WIN_GAME, MIN_LEAD_TO_WIN, DECIDING_GAME_SWAP_POINT } from "../common/Constants"

type UndoAction = () => void

@ObservedV2
export class ScoreViewModel {
  @Trace config: MatchConfig = new MatchConfig()
  @Trace state: ScoreState = new ScoreState()

  private undoStack: UndoAction[] = []

  initMatch(config: MatchConfig): void {
    this.config = config
    this.state = new ScoreState()
    this.undoStack = []
  }

  scorePoint(side: PlayerSide): void {
    if (this.state.phase === "match_over") {
      return
    }

    const state = this.state
    const isLeft = side === "left"

    const prevPointsLeft = state.pointsLeft
    const prevPointsRight = state.pointsRight
    const prevPhase = state.phase
    const prevShouldSwap = state.shouldSwapSides
    const prevSwapReason = state.swapReason

    if (isLeft) {
      state.pointsLeft++
    } else {
      state.pointsRight++
    }

    const undoFn = (): void => {
      state.pointsLeft = prevPointsLeft
      state.pointsRight = prevPointsRight
      state.phase = prevPhase
      state.shouldSwapSides = prevShouldSwap
      state.swapReason = prevSwapReason
    }
    this.undoStack.push(undoFn)

    if (this.isGameWon()) {
      this.handleGameWon(side)
      return
    }

    this.checkDecidingGameSwap()
  }

  deductPoint(side: PlayerSide): void {
    if (this.state.phase !== "playing") {
      return
    }
    const isLeft = side === "left"
    if (isLeft && this.state.pointsLeft > 0) {
      this.state.pointsLeft--
    } else if (!isLeft && this.state.pointsRight > 0) {
      this.state.pointsRight--
    }
  }

  confirmSwapSides(): void {
    if (!this.state.shouldSwapSides) {
      return
    }
    // 局结束时：比分即将重置，只需要翻转 sidesSwapped 标记
    // 决胜局5分时：需要交换分数显示位置
    if (this.state.phase === "playing") {
      // 决胜局中途换场：交换分数
      const temp = this.state.pointsLeft
      this.state.pointsLeft = this.state.pointsRight
      this.state.pointsRight = temp
    }
    // 翻转换场标记
    this.state.sidesSwapped = !this.state.sidesSwapped
    this.state.shouldSwapSides = false
    this.state.swapReason = ""
  }

  undo(): void {
    if (this.undoStack.length === 0) {
      return
    }
    const undoFn = this.undoStack.pop()
    if (undoFn) {
      undoFn()
    }
  }

  startNextGame(): void {
    if (this.state.phase !== "game_over") {
      return
    }
    this.state.pointsLeft = 0
    this.state.pointsRight = 0
    this.state.currentGame++
    this.state.phase = "playing"
    // sidesSwapped 保持上一局确认的换场方向
    // 仅在决胜局开始时重置（但决胜局开始时 currentGame 已递增，
    // 如果上一局 confirmSwapSides 已经翻了 sidesSwapped，则保持）
  }

  getDisplayName(side: PlayerSide): string {
    if (side === "left") {
      return this.state.sidesSwapped ? this.config.playerRightName : this.config.playerLeftName
    }
    return this.state.sidesSwapped ? this.config.playerLeftName : this.config.playerRightName
  }

  getDisplayScore(side: PlayerSide): number {
    if (side === "left") {
      return this.state.sidesSwapped ? this.state.pointsRight : this.state.pointsLeft
    }
    return this.state.sidesSwapped ? this.state.pointsLeft : this.state.pointsRight
  }

  getDisplayGames(side: PlayerSide): number {
    if (side === "left") {
      return this.state.sidesSwapped ? this.state.gamesRight : this.state.gamesLeft
    }
    return this.state.sidesSwapped ? this.state.gamesLeft : this.state.gamesRight
  }

  private isGameWon(): boolean {
    const left = this.state.pointsLeft
    const right = this.state.pointsRight
    if (left >= SCORE_TO_WIN_GAME && left - right >= MIN_LEAD_TO_WIN) {
      return true
    }
    if (right >= SCORE_TO_WIN_GAME && right - left >= MIN_LEAD_TO_WIN) {
      return true
    }
    return false
  }

  private handleGameWon(winner: PlayerSide): void {
    const state = this.state
    const gameResult: GameResult = {
      gameNumber: state.currentGame,
      scoreLeft: state.pointsLeft,
      scoreRight: state.pointsRight
    }

    const prevGamesLeft = state.gamesLeft
    const prevGamesRight = state.gamesRight
    const prevHistory: GameResult[] = state.history.slice(0)
    const prevPhase = state.phase
    const prevWinner = state.winner
    const prevShouldSwap = state.shouldSwapSides
    const prevSwapReason = state.swapReason
    const prevSidesSwapped = state.sidesSwapped
    const prevCurrentGame = state.currentGame
    const prevPointsLeft = state.pointsLeft
    const prevPointsRight = state.pointsRight

    state.history = [...state.history, gameResult]

    if (winner === "left") {
      state.gamesLeft++
    } else {
      state.gamesRight++
    }

    if (state.gamesLeft >= this.config.gamesToWin) {
      state.phase = "match_over"
      state.winner = "left"
    } else if (state.gamesRight >= this.config.gamesToWin) {
      state.phase = "match_over"
      state.winner = "right"
    } else {
      state.phase = "game_over"
      state.shouldSwapSides = true
      state.swapReason = "局结束，交换场地"
    }

    // 替换上一步的撤销为更完整的撤销
    this.undoStack.pop()
    const undoFn = (): void => {
      state.pointsLeft = prevPointsLeft
      state.pointsRight = prevPointsRight
      state.gamesLeft = prevGamesLeft
      state.gamesRight = prevGamesRight
      state.history = prevHistory
      state.phase = prevPhase
      state.winner = prevWinner
      state.shouldSwapSides = prevShouldSwap
      state.swapReason = prevSwapReason
      state.sidesSwapped = prevSidesSwapped
      state.currentGame = prevCurrentGame
    }
    this.undoStack.push(undoFn)
  }

  private checkDecidingGameSwap(): void {
    const state = this.state
    if (!this.config.isDecidingGame(state.currentGame)) {
      return
    }
    if (state.sidesSwapped) {
      return
    }
    if (state.pointsLeft >= DECIDING_GAME_SWAP_POINT || state.pointsRight >= DECIDING_GAME_SWAP_POINT) {
      state.shouldSwapSides = true
      state.swapReason = "决胜局 5 分，交换场地"
    }
  }
}
