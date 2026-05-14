import { ScoreViewModel } from "../viewmodel/ScoreViewModel"
import { MatchConfig } from "../model/MatchConfig"
import { SetupPage } from "./SetupPage"
import { ScoreboardPage } from "./ScoreboardPage"
import { HistoryPage } from "./HistoryPage"

type AppPage = "setup" | "scoreboard" | "history"

@ComponentV2
struct MainPage {
  @Local currentPage: AppPage = "setup"
  @Local viewModel: ScoreViewModel = new ScoreViewModel()

  build() {
    Column() {
      if (this.currentPage === "setup") {
        SetupPage({
          onStart: (config: MatchConfig) => {
            this.viewModel.initMatch(config)
            this.currentPage = "scoreboard"
          }
        })
      } else if (this.currentPage === "scoreboard") {
        ScoreboardPage({
          viewModel: this.viewModel,
          onNewMatch: () => {
            this.currentPage = "setup"
          },
          onMatchEnd: () => {
            // 比赛结束，跳转到设置或记录
            this.currentPage = "setup"
          }
        })
      } else if (this.currentPage === "history") {
        HistoryPage({
          onBack: () => {
            this.currentPage = "setup"
          }
        })
      }
    }
    .width("100%")
    .height("100%")
  }
}

export { MainPage }
