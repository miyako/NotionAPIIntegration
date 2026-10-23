# 4DとNotionの連携：Notion APIによるページとデータベースの作成

Integrating 4D with Notion: Creating Pages and Databases Using the Notion API (Technical Note 25-08): Japanese edition.

このテクニカルノートでは、4DのHTTPRequestクラスを使用してNotion APIを呼び出し、Notionのデータベースとページに対してCRUD（作成・読み取り・更新・削除）操作を実行する方法を解説します。Notionの内部インテグレーションの作成、認証キーとデータベースIDの取得、各APIエンドポイントの使い方、4DのデータとNotionのプロパティの対応付けを順に説明します。付属のデモは在庫管理アプリケーションで、Notionの「Inventory Manager」データベースから在庫を読み込み、4Dから商品の追加・在庫の更新・削除を行います。Qodly StudioのWebページからも同じデータを操作できます。

This technical note shows how to call the Notion API from 4D with the HTTPRequest class to create, read, update and delete pages in a Notion database. The demo is an inventory manager synchronised with the Notion "Inventory Manager" template.

## Download

| | |
|---|---|
| PDF (日本語) | [25-08_NotionAPIIntegration_ja.pdf](https://github.com/miyako/NotionAPIIntegration/releases/latest/download/25-08_NotionAPIIntegration_ja.pdf) |
| 4D demo | [NotionAPIIntegration.zip](https://github.com/miyako/NotionAPIIntegration/releases/latest/download/NotionAPIIntegration.zip) |
| Original (English) | `document/25-08_NotionAPIIntegration.pdf` |

## Demo

- 4D version: 4D 20 R9 or later (the project was verified with tool4d 21 R3)
- Open `demo/NotionAPIIntegration/Project/NotionAPIIntegration.4DProject`.
- Languages: English, Japanese. The UI follows the system language; the XLIFF files are in `Resources/<lang>.lproj/`.
- At startup, the demo asks for the Notion internal integration secret and the database ID (see the note), then opens the inventory window without blocking. **File > Inventory Manager** reopens it.
- The Qodly Studio page (`StocksPage`) is in English. To open it: **Run > Start Web Server**, then **Design > Qodly Studio...** and **Preview**.

## Differences from the original

- The demo UI (forms, list box headers, buttons and messages) is localised with XLIFF in English and Japanese.
  Status and category values ("In Stock", "Apparel"...) stay in English because they are option names in the Notion database.
- The startup no longer blocks: a `startup` method opens the main window in the application process, and a File menu item reopens it.
  The code in the note still shows the original startup code.
- Missing local variable declarations were added so that the project compiles.
- The Notion token in a commented-out line of `updateStock` was replaced with a placeholder, and the demo's private TLS key (`key.pem`, `csr.txt`) is not included.
- The Notion integration secret that appears in the original's code examples was replaced with `<your Notion integration secret>`, and the sample secret with `ntn_XXXX...`.
- The screenshots are the original English ones.
- The title page doesn't show the technical note number.

## Editing and rebuilding

The PDF is generated from plain-text sources. Edit them and run `make`.

| File | What |
|---|---|
| `src/ja.md` | Translated body text. **Don't touch code blocks** (`make check` verifies them). |
| `figures/layout/fig-NN.json` | Figure settings; all figures are screenshots copied unchanged (`"localize": false`). `"replace"` uses a ready-made image |
| `glossary.md` | Terminology |

```sh
make            # check → figures → build/25-08_NotionAPIIntegration_ja.pdf
make check      # code blocks unchanged, figure references complete
make review     # contact sheets of the figures (build/contact-N.png)
make release-assets
```

Requirements: Python 3, Google Chrome, CJK fonts, and Tesseract (only needed for re-extraction).
See the [localisation template](https://github.com/miyako/4d-technote-localisation-template) for the full workflow.

## Credits

- Original: Al Mahdi Bakkali, Quality Support Engineer, 4D Inc.
- Produced with [4d-technote-localisation-template](https://github.com/miyako/4d-technote-localisation-template) and GitHub Copilot.
