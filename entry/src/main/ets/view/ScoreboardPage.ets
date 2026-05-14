import { ScoreViewModel } from "../viewmodel/ScoreViewModel"
import { ScoreDisplay } from "./ScoreDisplay"
import { SwapSidesDialog } from "./SwapSidesDialog"
import { PlayerSide } from "../model/MatchConfig"

@ComponentV2
struct ScoreboardPage {
  @Param viewModel: ScoreViewModel = new ScoreViewModel()
  @Param onNewMatch: () => void = () => {}
  @Param onMatchEnd: () => void = () => {}
  @Local showSwapDialog: boolean = false

  @Monitor("viewModel.state.shouldSwapSides")
  onShouldSwapSidesChange(): void {
    if (this.viewModel.state.shouldSwapSides && !this.showSwapDialog) {
      this.showSwapDialog = true
    }
  }

  build() {
    Column() {
      this.TopBar()
      this.ScoreArea()
      this.ActionBar()
    }
    .width("100%")
    .height("100%")
    .backgroundColor($r("app.color.bg_primary"))
    .padding({ left: 24, right: 24, top: 16, bottom: 16 })
    .bindContentCover(this.showSwapDialog, this.SwapOverlay(), {
      modalTransition: ModalTransition.NONE,
      backgroundColor: Color.Transparent
    })
  }

  @Builder
  TopBar() {
    Row() {
      Text(`第${this.viewModel.state.currentGame}局`)
        .fontSize(18)
        .fontColor($r("app.color.text_secondary"))

      Text(`BO${this.viewModel.config.bestOf}`)
        .fontSize(18)
        .fontColor($r("app.color.text_hint"))
        .margin({ left: 12 })

      Blank()

      Text(`局分 ${this.viewModel.getDisplayGames("left")} : ${this.viewModel.getDisplayGames("right")}`)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor($r("app.color.text_primary"))
    }
    .width("100%")
    .height(48)
  }

  @Builder
  ScoreArea() {
    Row() {
      Column() {
        ScoreDisplay({
          score: this.viewModel.getDisplayScore("left"),
          playerName: this.viewModel.getDisplayName("left"),
          isLeading: this.viewModel.getDisplayScore("left") > this.viewModel.getDisplayScore("right"),
          accentColor: $r("app.color.accent_left")
        })
      }
      .layoutWeight(1)
      .height("100%")

      Column() {
        Text(":")
          .fontSize(64)
          .fontWeight(FontWeight.Bold)
          .fontColor("#444444")
      }
      .width(60)
      .justifyContent(FlexAlign.Center)

      Column() {
        ScoreDisplay({
          score: this.viewModel.getDisplayScore("right"),
          playerName: this.viewModel.getDisplayName("right"),
          isLeading: this.viewModel.getDisplayScore("right") > this.viewModel.getDisplayScore("left"),
          accentColor: $r("app.color.accent_right")
        })
      }
      .layoutWeight(1)
      .height("100%")
    }
    .width("100%")
    .layoutWeight(1)
    .margin({ top: 16, bottom: 16 })
  }

  @Builder
  ActionBar() {
    Column() {
      Row() {
        Button("−")
          .fontSize(24)
          .fontColor($r("app.color.text_primary"))
          .backgroundColor("#333355")
          .borderRadius(12)
          .width(64)
          .height(64)
          .onClick(() => this.viewModel.deductPoint(this.getActualSide("left")))

        Button($r("app.string.btn_my_point"))
          .fontSize(22)
          .fontColor($r("app.color.text_primary"))
          .backgroundColor($r("app.color.accent_left"))
          .borderRadius(12)
          .layoutWeight(1)
          .height(64)
          .onClick(() => this.viewModel.scorePoint(this.getActualSide("left")))

        Blank().width(24)

        Button($r("app.string.btn_opponent_point"))
          .fontSize(22)
          .fontColor($r("app.color.text_primary"))
          .backgroundColor($r("app.color.accent_right"))
          .borderRadius(12)
          .layoutWeight(1)
          .height(64)
          .onClick(() => this.viewModel.scorePoint(this.getActualSide("right")))

        Button("−")
          .fontSize(24)
          .fontColor($r("app.color.text_primary"))
          .backgroundColor("#333355")
          .borderRadius(12)
          .width(64)
          .height(64)
          .onClick(() => this.viewModel.deductPoint(this.getActualSide("right")))
      }
      .width("100%")
      .margin({ bottom: 12 })

      Row() {
        Button($r("app.string.btn_undo"))
          .fontSize(16)
          .fontColor($r("app.color.text_secondary"))
          .backgroundColor($r("app.color.bg_button"))
          .borderRadius(8)
          .width(80)
          .height(44)
          .onClick(() => this.viewModel.undo())

        Blank()

        if (this.viewModel.state.phase === "game_over") {
          Button($r("app.string.btn_next_game"))
            .fontSize(16)
            .fontColor($r("app.color.text_primary"))
            .backgroundColor($r("app.color.accent_left"))
            .borderRadius(8)
            .width(100)
            .height(44)
            .onClick(() => {
              this.viewModel.confirmSwapSides()
              this.viewModel.startNextGame()
            })
        }

        if (this.viewModel.state.phase === "match_over") {
          Button($r("app.string.btn_new_match"))
            .fontSize(16)
            .fontColor($r("app.color.text_primary"))
            .backgroundColor($r("app.color.accent_right"))
            .borderRadius(8)
            .width(100)
            .height(44)
            .onClick(() => this.onMatchEnd())
        }

        Blank()

        Button($r("app.string.btn_new_match"))
          .fontSize(16)
          .fontColor($r("app.color.text_secondary"))
          .backgroundColor($r("app.color.bg_button"))
          .borderRadius(8)
          .width(80)
          .height(44)
          .onClick(() => this.onNewMatch())
      }
      .width("100%")
    }
  }

  @Builder
  SwapOverlay() {
    Column() {
      SwapSidesDialog({
        reason: this.viewModel.state.swapReason,
        onConfirm: () => {
          this.viewModel.confirmSwapSides()
          this.showSwapDialog = false
          if (this.viewModel.state.phase === "game_over") {
            this.viewModel.startNextGame()
          }
        }
      })
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#B3000000")
    .justifyContent(FlexAlign.Center)
    .padding({ left: 60, right: 60 })
  }

  private getActualSide(displaySide: PlayerSide): PlayerSide {
    if (this.viewModel.state.sidesSwapped) {
      return displaySide === "left" ? "right" : "left"
    }
    return displaySide
  }
}

export { ScoreboardPage }
