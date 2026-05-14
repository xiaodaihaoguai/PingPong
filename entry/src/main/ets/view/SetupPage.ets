import { MatchConfig } from "../model/MatchConfig"

@ComponentV2
struct SetupPage {
  @Local bestOf: number = 5
  @Local playerLeftName: string = "我"
  @Local playerRightName: string = "对手"
  @Event onStart: (config: MatchConfig) => void = (_config: MatchConfig) => {}

  private bestOfOptions: number[] = [3, 5, 7]

  build() {
    Column() {
      Text($r("app.string.page_setup"))
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor($r("app.color.text_primary"))
        .margin({ bottom: 40 })

      Column() {
        Text($r("app.string.label_best_of"))
          .fontSize(18)
          .fontColor($r("app.color.text_secondary"))
          .margin({ bottom: 12 })

        Row() {
          ForEach(this.bestOfOptions, (option: number) => {
            Button(`BO${option}`)
              .fontSize(18)
              .fontColor(this.bestOf === option ? $r("app.color.text_primary") : $r("app.color.text_secondary"))
              .backgroundColor(this.bestOf === option ? $r("app.color.accent_left") : $r("app.color.bg_button"))
              .borderRadius(8)
              .layoutWeight(1)
              .height(48)
              .margin({ left: 4, right: 4 })
              .onClick(() => {
                this.bestOf = option
              })
          }, (option: number) => `${option}`)
        }
        .width("100%")
      }
      .width("100%")
      .margin({ bottom: 32 })

      Column() {
        Text("选手（左）")
          .fontSize(18)
          .fontColor($r("app.color.text_secondary"))
          .margin({ bottom: 8 })

        TextInput({ text: this.playerLeftName, placeholder: $r("app.string.hint_player_name") })
          .fontSize(18)
          .fontColor($r("app.color.text_primary"))
          .backgroundColor($r("app.color.bg_card"))
          .borderRadius(8)
          .width("100%")
          .height(48)
          .onChange((value: string) => {
            this.playerLeftName = value
          })
      }
      .width("100%")
      .margin({ bottom: 24 })

      Column() {
        Text("选手（右）")
          .fontSize(18)
          .fontColor($r("app.color.text_secondary"))
          .margin({ bottom: 8 })

        TextInput({ text: this.playerRightName, placeholder: $r("app.string.hint_player_name") })
          .fontSize(18)
          .fontColor($r("app.color.text_primary"))
          .backgroundColor($r("app.color.bg_card"))
          .borderRadius(8)
          .width("100%")
          .height(48)
          .onChange((value: string) => {
            this.playerRightName = value
          })
      }
      .width("100%")
      .margin({ bottom: 48 })

      Button($r("app.string.btn_start"))
        .fontSize(22)
        .fontColor($r("app.color.text_primary"))
        .backgroundColor($r("app.color.accent_left"))
        .borderRadius(12)
        .width("100%")
        .height(56)
        .onClick(() => {
          const config = new MatchConfig()
          config.bestOf = this.bestOf
          config.playerLeftName = this.playerLeftName
          config.playerRightName = this.playerRightName
          this.onStart(config)
        })
    }
    .width("100%")
    .height("100%")
    .backgroundColor($r("app.color.bg_primary"))
    .padding({ left: 48, right: 48, top: 32, bottom: 32 })
    .justifyContent(FlexAlign.Center)
  }
}

export { SetupPage }
