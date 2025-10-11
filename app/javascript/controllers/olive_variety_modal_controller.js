import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="olive-variety-modal"
export default class extends Controller {
  // static targets = ["content"]: 「このコントローラーが操作するHTML要素」に付けられたエイリアス（別名)を定義している。
  // data-olive-variety-modal-target="content" のように指定された要素を探し出し、JSのコードから this.contentTarget という名前でアクセスできるようにする
  static targets = ["content"]

  // 意味: data-olive-variety-modal-target="content" で指定された要素から、CSSクラスの "hidden" を削除
  // 効果: モーダルが非表示の状態（CSSで display: none; や opacity: 0; などが適用されている場合）から、表示状態に切り替わる
  open() {
    this.contentTarget.classList.remove("hidden")
  }

  // 意味: data-olive-variety-modal-target="content" で指定された要素に、CSSクラスの "hidden" を追加
  // 効果: モーダルが非表示状態に切り替わる
  close() {
    this.contentTarget.classList.add("hidden")
  }
}
