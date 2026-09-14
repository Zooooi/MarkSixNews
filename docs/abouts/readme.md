抱歉！是我誤會了。以下為您整理專為 **`About` 頁面動態 JSON UI 結構** 撰寫的 **README.md** 文件說明：

---

# About Page Dynamic UI Structure Documentation

本文件說明 `About` 頁面動態渲染 JSON 結構的設計規範、支援元件、樣式 Mapping 機制與資料結構定義。

---

## 1. 核心設計架構

動態 UI 採用 **Strategy Pattern（策略模式）** 與 **遞迴走訪（Recursive Traversal）** 實現：

* **JSON DSL**：以抽象語法樹（AST）結構描述 Flutter UI 佈局與屬性。
* **DynamicUiBuilder**：負責走訪 JSON 節點、解析樣式 Token 並呼叫對應的解析器。
* **WidgetParser**：各 Widget 的獨立解析器，負責將 JSON `attributes` 轉換為真正的 Flutter 組件。

---

## 2. Token 解析規則 (Design Tokens)

為確保 UI 風格一致性與主題切換支援，屬性值優先採用 Token 字串：

### 2.1 顏色 Token (`wc.*` / `tc.*` / Hex)

| Token 類別 | 範例 | 對應 Flutter 屬性 / 來源 |
| --- | --- | --- |
| **Widget 背景與邊框** | `wc.scaffoldBg`, `wc.cardColor`, `wc.divider`, `wc.activeColor`, `wc.borderColor1~3` | `context.widgetColors` |
| **文字顏色** | `tc.primary`, `tc.secondary`, `tc.third`, `tc.helpInfo` | `context.textColors` |
| **色碼 (Hex)** | `#FF0000`, `#333333` | 自訂 `Color` |

### 2.2 文字樣式 Token (`tt.*`)

對應 `context.textTheme`：

* `tt.titleLarge`, `tt.titleMedium`, `tt.titleSmall`
* `tt.bodyLarge`, `tt.bodyMedium`, `tt.bodySmall`
* `tt.labelLarge`, `tt.labelMedium`, `tt.labelSmall`
* `tt.displayLarge`, `tt.displayMedium`

### 2.3 間距與圓角 Token (`res.*`)

* **Padding / Space**：`res.padding_1` ~ `4` / `res.space_1` ~ `4`
* **Radius**：`res.radius_1` ~ `3`

---

## 3. 支援元件與屬性規格 (Supported Widgets)

### 3.1 容器與佈局類 (Layouts)

#### `Column`

* **Attributes**:
* `padding` *(String)*: 例如 `"res.padding_3"`
* `crossAxisAlignment` *(String)*: `"start"` | `"center"` | `"stretch"`


* **Children**: `children` *(Array of Nodes)*

#### `Row`

* **Attributes**:
* `crossAxisAlignment` *(String)*: `"start"` | `"center"`


* **Children**: `children` *(Array of Nodes)*

#### `SizedBox`

* **Attributes**:
* `height` *(String)*: 例如 `"res.space_3"`
* `width` *(String)*: 例如 `"res.space_2"`



#### `Expanded`

* **Attributes**:
* `flex` *(int)*: 預設 `1`


* **Child**: `child` *(Node)*

---

### 3.2 卡片與區塊類 (Cards & Containers)

#### `Card`

* **Attributes**:
* `title` *(String, Optional)*: 卡片標題
* `titleStyle` *(String)*: 標題字體 Token（如 `"tt.titleMedium"`）
* `titleColor` *(String)*: 標題顏色 Token（如 `"tc.primary"`）
* `titleAlignment` *(String)*: `"start"` | `"center"`
* `color` *(String)*: 背景色 Token（如 `"wc.cardColor"`）
* `border` *(String)*: 邊框顏色 Token（如 `"wc.borderColor3"`）
* `borderStroke` *(double/int)*: 邊框粗細（預設 `1.0`）
* `padding` *(String)*: 內邊距 Token
* `borderRadius` *(String)*: 圓角 Token


* **Child**: `child` *(Node)*

#### `HeaderCard`

* **Attributes**:
* `title` *(String)*: 標題
* `titleStyle` *(String)*: 文字樣式 Token
* `titleColor` *(String)*: 文字顏色 Token
* `logoUrl` *(String)*: 圖片網址
* `background` *(String)*: 背景色 Token
* `padding` / `borderRadius` *(String)*



---

### 3.3 列表與展示類 (List & Content)

#### `ListTile`

* **Attributes**:
* `leadingIcon` *(String)*: Emoji 或圖標字元（如 `"🌐"`）
* `title` *(String)*: 主要標題
* `titleStyle` / `titleColor` *(String)*: 標題樣式與顏色
* `trailingText` *(String)*: 右側尾隨文字
* `trailingStyle` / `trailingColor` *(String)*: 尾隨文字樣式與顏色
* `padding` *(String)*: 內邊距 Token
* `linkUrl` *(String, Optional)*: 點擊後開啟的外鏈 URL
* `copyData` *(String, Optional)*: 點擊後複製到剪貼簿的文字
* `actionIcon` *(String, Optional)*: 例如 `"copy"`



#### `Divider`

* **Attributes**:
* `color` *(String)*: 分隔線顏色 Token（如 `"wc.divider"`）



#### `Image`

* **Attributes**:
* `src` *(String)*: 圖片 URL
* `width` / `height` *(double/int)*: 尺寸
* `borderRadius` *(String)*: 圓角 Token



#### `Text`

* **Attributes**:
* `text` *(String)*: 文字內容
* `style` *(String)*: 文字樣式 Token
* `color` *(String)*: 文字顏色 Token
* `textAlign` *(String)*: `"start"` | `"center"`



#### `FeatureItem` ( Roadmap 特性項目 )

* **Attributes**:
* `tag` *(String)*: 狀態/模組標籤文字（如 `"MODULE_1: THEME [IN_DEV]"`）
* `tagStyle` / `tagColor` *(String)*: 標籤樣式與顏色
* `content` *(String)*: 特性詳細說明
* `contentStyle` / `contentColor` *(String)*: 說明內文樣式與顏色



---

## 4. JSON 範例 (About 頁面結構)

```json
{
  "type": "Column",
  "attributes": {
    "padding": "res.padding_3",
    "crossAxisAlignment": "stretch"
  },
  "children": [
    {
      "type": "Card",
      "attributes": {
        "title": "Home, Channels & Community",
        "titleStyle": "tt.titleMedium",
        "titleColor": "tc.primary",
        "titleAlignment": "center",
        "color": "wc.cardColor",
        "borderStroke": 4,
        "border": "wc.borderColor3",
        "padding": "res.padding_2",
        "borderRadius": "res.radius_2"
      },
      "child": {
        "type": "Column",
        "attributes": { "crossAxisAlignment": "stretch" },
        "children": [
          {
            "type": "ListTile",
            "attributes": {
              "leadingIcon": "🌐",
              "title": "Official Web",
              "titleStyle": "tt.bodyMedium",
              "titleColor": "tc.primary",
              "trailingText": "app.mark6stats.com",
              "trailingStyle": "tt.bodySmall",
              "trailingColor": "tc.secondary",
              "padding": "res.padding_4",
              "linkUrl": "https://app.mark6stats.com"
            }
          }
        ]
      }
    }
  ]
}

```

---

## 5. 容錯與擴充說明

1. **未知元件防爆機制**：若 JSON 包含未註冊的 `type`，`buildNode` 會發出警告 Log 並回傳 `SizedBox.shrink()`，確保整體頁面不崩潰。
2. **新增 Widget 解析器**：
1. 實作 `WidgetParser` 介面並指定 `widgetType`。
2. 在 `DynamicUiBuilder` 的建構子中執行 `_register(NewWidgetParser())` 即可完成擴充。