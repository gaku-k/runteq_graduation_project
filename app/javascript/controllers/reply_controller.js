import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reply"
export default class extends Controller {
  // コントローラーがHTML内で操作したい特定の要素を定義。
  // data-コントローラー名-target="form"という属性が付いている必要がある
  static targets = ["form"]

  // コントローラー内で定義されたアクションメソッド
  // HTML要素に data-action="[イベント]->[コントローラー名]#toggle" 属性が設定されたときに実行される
  toggle() {
    // 取得したフォーム要素のHTMLクラスリストにtoggleメソッドを実行.
    // hiddenクラスを付けたり外したりする
    this.formTarget.classList.toggle("hidden")
  }
}
