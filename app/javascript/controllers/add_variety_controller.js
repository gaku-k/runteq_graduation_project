import { Controller } from "@hotwired/stimulus"
// ユーザーが addField() に接続されたボタンをクリックするたびにフォームの入力欄を増やし、removeField() に接続されたボタンをクリックするたびにその入力欄を消す

// Connects to data-controller="add-variety"
export default class extends Controller {
  // fields: 新しいフィールドセットが挿入される、親となるコンテナ
  // template: 複製してフォームに追加するための、非表示の雛形（HTMLテンプレート）
  static targets = ["fields", "template"]

  addField() {
    // テンプレートを複製して、fields内に挿入
    // HTMLの <template> タグの中身（.content）を取得し、cloneNode(true) でその内容をすべて複製する
    const content = this.templateTarget.content.cloneNode(true)

    // 現在のタイムスタンプを使ってユニークなインデックスを作成
    const newIndex = new Date().getTime() 
    
    // テンプレート内の "__INDEX__" を一意のインデックスに置き換える
    const newHtml = content.firstElementChild.outerHTML.replace(/__INDEX__/g, newIndex)
    // 置き換え後のHTMLをfieldsコンテナに挿入
    this.fieldsTarget.insertAdjacentHTML('beforeend', newHtml)
  } 

  removeField(event) {
    // event.target: 削除ボタン（このアクションをトリガーした要素）
    // .remove(): 検出された .variety-field 要素とその中のすべての内容を DOM から削除
    event.target.closest(".variety-field").remove()
  }
}
