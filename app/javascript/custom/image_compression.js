import imageCompression from 'browser-image-compression';
console.log("JS読み込み成功");

// 保存ボタンの状態を切り替える関数。()は「引数の名前」
const setSubmitButtonDisabled = (disabled) => {
  const submitButtons = document.querySelectorAll('input[type="submit"], button[type="submit"]');
  if (submitButtons.length === 0) return;
  // console.log("DEBUG: #submitボタンを検知。");

  // forEach 1個ずつ順番に処理
  submitButtons.forEach(btn => {
    // 左:disabled(ボタンを押せなくするHTMLの属性).右は呼び出した時にtrueが渡される
    btn.disabled = disabled;
    // Railsの自動無効化(data-disable-with)と競合しないよう、直接書き換える

    // "Post"/"Share it!"などを一時メモ
    if (!btn.dataset.originalValue) {
      btn.dataset.originalValue = btn.value;
    }

    if (disabled) {
      btn.value = "圧縮中";
      // 不透明度(opacity), カーソルがボタンの上に乗ったときの形（Cursor）を「禁止マーク」に変える。
      btn.style.opacity = "0.5";
      btn.style.cursor = "not-allowed";
    } else {
      btn.value = btn.dataset.originalValue; // 元の文字
      btn.style.opacity = "1.0";
      btn.style.cursor = "pointer";
    }
  });
};

// const 名前 = () => { ... } という書き方は「変数に処理（関数）を代入する」という形
const initializeImageCompression = () => {
  const imageInputs = document.querySelectorAll('#post_images, #product_images');

  // 要素がなければ何もしない。
  if (imageInputs.length === 0) return;


  imageInputs.forEach(imageInput => {
    // 'change'HTML標準イベントの一つ.内容が確定・変更されたとき（画像選択やチェックボックスなど）
    // async（非同期処理）により、重たい処理でもブラウザのメインの動きは止まらない。
    // リサイズ中に保存したくはない(待ってから次に行きたい)が、ユーザー体験を損なうのと、browser-image-compression ライブラリの中で行われる処理が最初から「非同期（Promise）」としてしか提供されていないものが多いらしい
    imageInput.addEventListener('change', async (event) => {
      // console.log("DEBUG: ファイル選択検知");

      // 'change' イベントの種類、その詳細情報をブラウザから引数event(名前は自由)として受け取る
      // event.target.filesは<input type="file"> が持っている特別なプロパティでユーザーが選択したファイル一覧
      const files = event.target.files;
      if (files.length === 0) return;

      // 保存ボタンを無効化（自作メソッドの呼び出し）
      setSubmitButtonDisabled(true);
    
      const options = {
        // だいたい 1MB以下になるように圧縮
        maxSizeMB: 1,
        // 画像の長辺（縦 or 横）を最大 1200px にする
        maxWidthOrHeight: 1200,
        // true → 裏で処理する（画面が固まりにくい）
        useWebWorker: true
      };

      const compressedFiles = [];

      for (let i = 0; i < files.length; i++) {
        // try：失敗するかもしれない処理内容。失敗したらcatchの処理を行う
        try {
          console.log(`圧縮前: ${(files[i].size / 1024 / 1024).toFixed(2)} MB`);
          // files[i]（選ばれた1枚の画像）を、options の条件で圧縮して、圧縮が終わるまで待って(await)、完成したファイルを compressedFile に入れる
          const compressedFile = await imageCompression(files[i], options);
          console.log(`圧縮後: ${(compressedFile.size / 1024 / 1024).toFixed(2)} MB`);

          // new File(中身, ファイル名, 設定)でファイルオブジェクトを新しく作る構文
          // 圧縮してできた画像を、元と同じ名前・同じ種類の“新しいファイル”として作り直している
          const renamedFile = new File([compressedFile], files[i].name, { type: files[i].type });
          compressedFiles.push(renamedFile);

        } catch (error) {
          console.error("圧縮エラー:", error);
        }
      }

      // ブラウザが用意している「ファイルの受け渡し専用コンテナ」。imageInput.files は直接書き換えられない
      const dataTransfer = new DataTransfer();
      // 圧縮後のfileを一つずつDataTransferに詰めていく
      compressedFiles.forEach(file => dataTransfer.items.add(file));
      // <input type="file"> が持っているfilesをDataTransfer経由で作ったものに差し替える
      imageInput.files = dataTransfer.files;
    
      console.log("リサイズ完了！");

      // ボタンを元に戻す
      setSubmitButtonDisabled(false);
    })
  });
};

// 本筋の処理（画像の圧縮）を実際に動かすための「起動スイッチ」
// 'DOMContentLoaded': HTMLの読み込みが完了して、DOM（画面上の部品）がすべて準備できた時
document.addEventListener('turbo:load', initializeImageCompression);