# 任務說明：HTML 轉 Flutter Dynamic UI JSON

請將輸入的 HTML 內容，轉換為符合 Flutter `DynamicUiBuilder` 專案規範（`AI_JSON_SYNC_GUIDE.md`）的 JSON 結構。

---

## 一、 多檔案同步與版本規則 (Multi-file Sync Rules)

A 當用戶要求生成或修改 `abouts/` 頁面時，**必須同時生成或更新以下 4 個檔案**，確保語系與平台結構 100% 對齊：
1. `a_hk.json` (Android 繁體中文)
2. `a_en.json` (Android 英文)
3. `i_hk.json` (iOS 繁體中文)
4. `i_en.json` (iOS 英文)

B 當用戶要求生成或修改 `upgrade/{版本號時}` 頁面時，**必須同時生成或更新以下 4 個檔案**，確保語系與平台結構 100% 對齊：
1. `hk.json` (繁體中文)
2. `en.json` (英文)


---

## 二、 Token 顏色與樣式映射 (Strict Token Mapping)

嚴禁在 JSON 中寫死 Raw Hex 碼（除非指定特定圖片容器背景），所有顏色與文字樣式必須嚴格使用以下已註冊 Token：

### 1. Widget 顏色 (`wc.*`)
- 頁面背景：`wc.scaffoldBg`
- 卡片背景：`wc.cardColor`
- 分隔線：`wc.divider`
- 啟用 / 高亮標籤：`wc.activeColor`
- 邊框線條：`wc.borderColor1`, `wc.borderColor2`, `wc.borderColor3`

### 2. 文字顏色 (`tc.*`)
- 主要文字：`tc.primary`
- 次要文字：`tc.secondary`
- 第三文字：`tc.third`
- 輔助說明：`tc.helpInfo`

### 3. 文字排版樣式 (`tt.*`)
- 標題：`tt.titleLarge`, `tt.titleMedium`, `tt.titleSmall`
- 正文：`tt.bodyLarge`, `tt.bodyMedium`, `tt.bodySmall`
- 標籤：`tt.labelLarge`, `tt.labelMedium`, `tt.labelSmall`

### 4. 間距與圓角 (`res.*`)
- Padding: `res.padding_1` (4dp), `res.padding_2` (8dp), `res.padding_3` (16dp), `res.padding_4` (24dp)
- Space: `res.space_1` (4dp), `res.space_2` (8dp), `res.space_3` (16dp), `res.space_4` (24dp)
- Radius: `res.radius_1` (4dp), `res.radius_2` (8dp), `res.radius_3` (16dp)

---

## 三、 HTML 元素至 DSL Widget 映射表

| HTML / 語義元素 | 對應 JSON `type` | 必填 / 常用 attributes 規格 |
| :--- | :--- | :--- |
| **區塊容器** | `Column` | `"padding": "padding_X"`, `"crossAxisAlignment": "start"|"center"|"stretch"` |
| **水平排版** | `Row` | `"crossAxisAlignment": "start"|"center"|"stretch"` |
| **間距留白** | `SizedBox` | `"height": "space_X"`, `"width": "space_X"` |
| **卡片外框** | `Card` | `"title": "...", "titleStyle": "tt.titleMedium", "titleColor": "tc.primary", "color": "wc.cardColor", "border": "wc.borderColor3", "borderStroke": 1.0, "padding": "padding_3", "borderRadius": "radius_2"` *(內容放置於 `child`)* |
| **列表連結 / 動作項** | `ListTile` | `"leadingIcon": "🌐", "title": "...", "titleStyle": "tt.bodyMedium", "titleColor": "tc.primary", "trailingText": "...", "trailingStyle": "tt.bodySmall", "linkUrl": "https://...", "copyData": "..."` |
| **分隔線** | `Divider` | `"color": "wc.divider"` |
| **標題 / 段落** | `Text` | `"text": "...", "style": "tt.titleMedium"|"tt.bodyMedium", "color": "tc.primary"|"tc.secondary", "textAlign": "start"|"center"` |
| **圖片** | `Image` | `"src": "https://...", "width": 160, "height": 160, "borderRadius": "radius_1"` |
| **Roadmap / 特性** | `FeatureItem` | `"tag": "MODULE_1", "tagStyle": "tt.labelSmall", "tagColor": "wc.activeColor", "content": "...", "contentStyle": "tt.bodySmall", "contentColor": "tc.secondary"` |

---

## 四、 轉換輸出規範

1. 根節點必須是 `Column`，且 `crossAxisAlignment` 設為 `"stretch"`。
2. `Card` 內若有多個元素，必須將子元素封裝在 `child` -> `Column` -> `children` 階層中。
3. 元素之間的垂直距離，必須顯式插入 `SizedBox`（例如 `"height": "space_2"`）。
4. 輸出結果請直接提供合法的 JSON，或根據四檔同步原則分別輸出對應的 4 個檔案內容。

輸出 JSON例子如下：
{
  "type": "Card",
  "attributes": {
    "color": "wc.cardColor",
    "border": "wc.borderColor1",
    "borderRadius": "radius_2",
    "padding": "padding_3"
  },
  "child": {
    "type": "Column",
    "attributes": {
      "crossAxisAlignment": "start"
    },
    "children": [
      {
        "type": "Tag",
        "attributes": {
          "text": "HOT",
          "style": "tt.labelSmall",
          "color": "wc.buttonTip1",
          "textColor": "tc.primary",
          "borderRadius": "radius_1"
        }
      },
      {
        "type": "SizedBox",
        "attributes": {
          "height": "space_2"
        }
      },
      {
        "type": "Text",
        "attributes": {
          "text": "最新消息",
          "style": "tt.titleLarge",
          "color": "tc.primary"
        }
      },
      {
        "type": "SizedBox",
        "attributes": {
          "height": "space_1"
        }
      },
      {
        "type": "Text",
        "attributes": {
          "text": "請立即更新至最新版本。",
          "style": "tt.bodyMedium",
          "color": "tc.secondary"
        }
      },
      {
        "type": "SizedBox",
        "attributes": {
          "height": "space_2"
        }
      },
      {
        "type": "Image",
        "attributes": {
          "src": "[https://example.com/banner.png](https://example.com/banner.png)",
          "borderRadius": "radius_1"
        }
      }
    ]
  }
}