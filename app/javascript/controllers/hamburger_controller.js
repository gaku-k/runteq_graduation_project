// Stimulusの「Controller」クラスを継承している
import { Controller } from "@hotwired/stimulus"

// 下はこのjsがどのHTML要素に紐づくのかの目印
// 使い方としては<div data-controller="hamburger">...</div>と書くとこのjsが紐づく
// Connects to data-controller="hamburger"　※デフォコメ
export default class extends Controller {
  static targets = ["button", "menu"]
  // connectメソッド: このControllerがHTMLに紐づいた時に最初に呼ばれるメソッド
  connect() {
    // openというプロパティ(状態)を(ここで初めて)作って、初期値をfalseにしている
    this.open = false
  }

  // html側のdata-action="click->hamburger#toggle" に紐づけている
  toggle() {
    this.open = !this.open
    // element.classList.toggle(className, force)というメソッドで、上のtoggleとは別物。
    // this.openがtrueならclass="change"を追加し、falseなら削除する
    this.buttonTarget.classList.toggle("change", this.open)
    this.menuTarget.classList.toggle("hidden", !this.open)
  }
}
