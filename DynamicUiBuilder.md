# AI JSON 專案同步維護指南 (AI_JSON_SYNC_GUIDE.md)

## 一、 適用範圍與檔案路徑 (Scope & Target Directories)

本規範與 JSON UI 構建格式 **嚴格適用於以下資料夾內的所有多語言 JSON 配置檔**：

1. **`abouts/` 資料夾**（關於頁面）：
   - `abouts/a_hk.json` (Android 繁體中文)
   - `abouts/a_en.json` (Android 英文)
   - `abouts/i_hk.json` (iOS 繁體中文)
   - `abouts/i_en.json` (iOS 英文)

2. **`upgrade/{version}/` 資料夾**（版本更新說明，例如 `upgrade/1.0.0/`）：
   - `upgrade/{version}/a_hk.json`
   - `upgrade/{version}/a_en.json`
   - `upgrade/{version}/i_hk.json`
   - `upgrade/{version}/i_en.json`

---

## 二、 AI 操作與版本維護規則 (Execution Rules)

1. **版本號動態匹配**：當收到 `upgrade` 的修改指示時，AI 應根據用戶指定的版本號（如 `v1.2.0`），自動將檔案定位於 `upgrade/{version}/` 路徑下。
2. **四檔同步（Atomic Update）**：每次更新不論位於 `abouts/` 或特定的 `upgrade/{version}/`，**必須同時同步該目錄下的全部 4 個檔案**（`a_hk` / `a_en` / `i_hk` / `i_en`），確保跨平台與語系結構 100% 對齊。

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

## 3. 支援元件與屬性規格 (Supported Widgets)

### 3.1 容器與佈局類 (Layouts)

#### `Column`
* **Attributes**:
  * `padding` *(String, Optional)*: 內邊距 Token（例如 `"res.padding_3"`）
  * `crossAxisAlignment` *(String, Optional)*: `"start"` | `"center"` | `"stretch"` (預設 `"start"`)
* **Children**: `children` *(Array of Nodes, Required)*

#### `Row`
* **Attributes**:
  * `crossAxisAlignment` *(String, Optional)*: `"start"` | `"center"` | `"stretch"`
* **Children**: `children` *(Array of Nodes, Required)*

#### `Container` (區塊/白底包裹容器)
* **Attributes**:
  * `color` *(String, Optional)*: 背景色 Token 或 Hex 色碼（如 `"#FFFFFF"`、`"wc.cardColor"`）
  * `padding` *(String, Optional)*: 內邊距 Token（如 `"res.padding_2"`）
  * `borderRadius` *(String, Optional)*: 圓角 Token（如 `"res.radius_1"`）
  * `width` / `height` *(double/int, Optional)*: 指定寬高
* **Child**: `child` *(Node, Optional)*

#### `SizedBox`
* **Attributes**:
  * `height` *(String/double, Optional)*: 間距 Token（如 `"res.space_3"`）或數值
  * `width` *(String/double, Optional)*: 間距 Token（如 `"res.space_2"`）或數值

#### `Expanded`
* **Attributes**:
  * `flex` *(int, Optional)*: 預設 `1`
* **Child**: `child` *(Node, Required)*

---

### 3.2 卡片與區塊類 (Cards & Containers)

#### `Card`
* **Attributes**:
  * `title` *(String, Optional)*: 卡片標題
  * `titleStyle` *(String, Optional)*: 標題字體 Token（如 `"tt.titleMedium"`）
  * `titleColor` *(String, Optional)*: 標題顏色 Token（如 `"tc.primary"`）
  * `titleAlignment` *(String, Optional)*: `"start"` | `"center"`
  * `color` *(String, Optional)*: 背景色 Token（如 `"wc.cardColor"`）
  * `border` *(String, Optional)*: 邊框顏色 Token（如 `"wc.borderColor3"`）
  * `borderStroke` *(double/int, Optional)*: 邊框粗細（預設 `1.0`）
  * `padding` *(String, Optional)*: 內邊距 Token
  * `borderRadius` *(String, Optional)*: 圓角 Token
* **Child**: `child` *(Node, Optional)*

---

### 3.3 列表與展示類 (List & Content)

#### `ListTile`
* **Attributes**:
  * `leadingIcon` *(String, Optional)*: Emoji 或圖標字元（如 `"🌐"`）
  * `title` *(String, Required)*: 主要標題
  * `titleStyle` / `titleColor` *(String, Optional)*: 標題樣式與顏色 Token
  * `trailingText` *(String, Optional)*: 右側尾隨文字
  * `trailingStyle` / `trailingColor` *(String, Optional)*: 尾隨文字樣式與顏色 Token
  * `padding` *(String, Optional)*: 內邊距 Token
  * `linkUrl` *(String, Optional)*: 點擊後開啟的外鏈 URL
  * `copyData` *(String, Optional)*: 點擊後複製到剪貼簿的文字

#### `Divider`
* **Attributes**:
  * `color` *(String, Optional)*: 分隔線顏色 Token（如 `"wc.divider"`）

#### `Image`
* **Attributes**:
  * `src` *(String, Required)*: 圖片 URL
  * `width` / `height` *(double/int, Optional)*: 尺寸
  * `borderRadius` *(String, Optional)*: 圓角 Token

#### `Text`
* **Attributes**:
  * `text` *(String, Required)*: 文字內容
  * `style` *(String, Optional)*: 文字樣式 Token
  * `color` *(String, Optional)*: 文字顏色 Token
  * `textAlign` *(String, Optional)*: `"start"` | `"center"` | `"end"`

#### `FeatureItem` (Roadmap 特性項目)
* **Attributes**:
  * `tag` *(String, Required)*: 狀態/模組標籤文字（如 `"MODULE_1: THEME"`）
  * `tagStyle` / `tagColor` *(String, Optional)*: 標籤樣式與背景顏色 Token
  * `content` *(String, Required)*: 特性詳細說明
  * `contentStyle` / `contentColor` *(String, Optional)*: 說明內文樣式與顏色 Token



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
        "borderWidth": 4,
        "borderColor": "wc.borderColor3",
        "padding": "res.padding_2",
        "borderRadius": "res.radius_2"
      },
      "child": {
        "type": "Column",
        "attributes": {
          "crossAxisAlignment": "stretch"
        },
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
          },
          {
            "type": "Divider",
            "attributes": {
              "color": "wc.divider"
            }
          },
          {
            "type": "ListTile",
            "attributes": {
              "leadingIcon": "💬",
              "title": "Community Group",
              "titleStyle": "tt.bodyMedium",
              "titleColor": "tc.primary",
              "trailingText": "@mark6statsGroup",
              "trailingStyle": "tt.bodySmall",
              "trailingColor": "tc.secondary",
              "copyData": "@mark6statsGroup"
            }
          }
        ]
      }
    },
    {
      "type": "SizedBox",
      "attributes": {
        "height": "res.space_2"
      }
    },
    {
      "type": "Card",
      "attributes": {
        "title": "Android App Download",
        "titleStyle": "tt.titleMedium",
        "titleColor": "tc.primary",
        "titleAlignment": "center",
        "color": "wc.cardColor",
        "borderColor": "wc.borderColor3",
        "padding": "res.padding_3",
        "borderRadius": "res.radius_2"
      },
      "child": {
        "type": "Column",
        "attributes": {
          "crossAxisAlignment": "center"
        },
        "children": [
          {
            "type": "Container",
            "attributes": {
              "color": "#FFFFFF",
              "padding": "res.padding_2",
              "borderRadius": "res.radius_1"
            },
            "child": {
              "type": "Image",
              "attributes": {
                "src": "https://n.mark6stats.com/images/android.png",
                "width": 160,
                "height": 160
              }
            }
          },
          {
            "type": "SizedBox",
            "attributes": {
              "height": "res.space_2"
            }
          },
          {
            "type": "Text",
            "attributes": {
              "text": "Scan QR Code to download directly on Google Play.",
              "textAlign": "center",
              "style": "tt.bodySmall",
              "color": "tc.secondary"
            }
          }
        ]
      }
    },
    {
      "type": "SizedBox",
      "attributes": {
        "height": "res.space_2"
      }
    },
    {
      "type": "Card",
      "attributes": {
        "title": "Future Roadmap",
        "titleStyle": "tt.titleMedium",
        "titleColor": "tc.primary",
        "color": "wc.cardColor",
        "padding": "res.padding_3",
        "borderRadius": "res.radius_2"
      },
      "child": {
        "type": "Column",
        "attributes": {
          "crossAxisAlignment": "start"
        },
        "children": [
          {
            "type": "FeatureItem",
            "attributes": {
              "tag": "1 : THEME & DYNAMIC UI",
              "tagStyle": "tt.labelSmall",
              "tagColor": "wc.activeColor",
              "content": "Provides 18 theme color schemes and adaptive UI support.",
              "contentStyle": "tt.bodySmall",
              "contentColor": "tc.secondary"
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