@ComponentV2
struct ScoreDisplay {
  @Param score: number = 0
  @Param playerName: string = ""
  @Param isLeading: boolean = false
  @Param accentColor: ResourceStr = "#4ECDC4"

  build() {
    Column() {
      Text(`${this.score}`)
        .fontSize(120)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isLeading ? this.accentColor : $r("app.color.text_primary"))
        .margin({ bottom: 8 })

      Text(this.playerName)
        .fontSize(24)
        .fontColor($r("app.color.text_secondary"))
    }
    .width("100%")
    .height("100%")
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r("app.color.bg_card"))
    .borderRadius(16)
  }
}

export { ScoreDisplay }
