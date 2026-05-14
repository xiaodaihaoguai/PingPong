@ComponentV2
struct SwapSidesDialog {
  @Param reason: string = ""
  @Event onConfirm: () => void = () => {}

  build() {
    Column() {
      Text($r("app.string.title_swap_sides"))
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor($r("app.color.text_primary"))
        .margin({ bottom: 16 })

      Text(this.reason)
        .fontSize(20)
        .fontColor($r("app.color.text_secondary"))
        .margin({ bottom: 32 })

      Button($r("app.string.btn_confirm_swap"))
        .fontSize(20)
        .fontColor($r("app.color.text_primary"))
        .backgroundColor($r("app.color.accent_right"))
        .borderRadius(12)
        .width(200)
        .height(56)
        .onClick(() => this.onConfirm())
    }
    .width("100%")
    .padding(32)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor("#16213E")
    .borderRadius(24)
  }
}

export { SwapSidesDialog }
