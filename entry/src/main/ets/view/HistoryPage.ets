import { GameResult } from "../model/ScoreState"

interface HistoryItem {
  id: number
  date: string
  playerLeft: string
  playerRight: string
  score: string
  winner: string
  games: GameResult[]
}

@ComponentV2
struct HistoryPage {
  @Param matches: HistoryItem[] = []
  @Event onBack: () => void = () => {}

  build() {
    Column() {
      Row() {
        Button("返回")
          .fontSize(16)
          .fontColor($r("app.color.accent_left"))
          .backgroundColor(Color.Transparent)
          .onClick(() => this.onBack())

        Blank()

        Text($r("app.string.page_history"))
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r("app.color.text_primary"))

        Blank()

        Text(" ")
          .fontSize(16)
      }
      .width("100%")
      .height(56)
      .padding({ left: 16, right: 16 })

      if (this.matches.length === 0) {
        Column() {
          Text("暂无比赛记录")
            .fontSize(18)
            .fontColor($r("app.color.text_hint"))
        }
        .width("100%")
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.matches, (match: HistoryItem) => {
            ListItem() {
              this.MatchCard(match)
            }
            .margin({ bottom: 12 })
          }, (match: HistoryItem) => `${match.id}`)
        }
        .width("100%")
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      }
    }
    .width("100%")
    .height("100%")
    .backgroundColor($r("app.color.bg_primary"))
  }

  @Builder
  MatchCard(match: HistoryItem) {
    Column() {
      Row() {
        Text(match.date)
          .fontSize(14)
          .fontColor($r("app.color.text_hint"))

        Blank()

        Text(match.score)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r("app.color.text_primary"))

        Blank()

        Text(match.winner + " 胜")
          .fontSize(14)
          .fontColor($r("app.color.accent_left"))
      }
      .width("100%")
      .margin({ bottom: 8 })

      Row() {
        Text(match.playerLeft)
          .fontSize(16)
          .fontColor($r("app.color.text_secondary"))

        Text(" vs ")
          .fontSize(14)
          .fontColor($r("app.color.text_hint"))

        Text(match.playerRight)
          .fontSize(16)
          .fontColor($r("app.color.text_secondary"))
      }
      .width("100%")

      Row() {
        ForEach(match.games, (game: GameResult) => {
          Text(`第${game.gameNumber}局 ${game.scoreLeft}:${game.scoreRight}`)
            .fontSize(12)
            .fontColor("#888888")
            .margin({ right: 12 })
        }, (game: GameResult) => `${game.gameNumber}`)
      }
      .width("100%")
      .margin({ top: 8 })
    }
    .width("100%")
    .padding(16)
    .backgroundColor($r("app.color.bg_card"))
    .borderRadius(12)
  }
}

export { HistoryPage }
