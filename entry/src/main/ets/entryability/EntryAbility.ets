import { AbilityConstant, UIAbility, Want } from "@kit.AbilityKit"
import { window } from "@kit.ArkUI"

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
  }

  onDestroy(): void {
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent("pages/Index", (err) => {
      if (err.code) {
        return
      }
      // 锁定横屏
      windowStage.getMainWindow().then((win: window.Window) => {
        win.setPreferredOrientation(window.Orientation.LANDSCAPE)
      })
    })
  }

  onWindowStageDestroy(): void {
  }

  onForeground(): void {
  }

  onBackground(): void {
  }
}
