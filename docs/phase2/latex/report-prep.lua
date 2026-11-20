-- Pandoc Lua filter to align docs/phase2/report.md with the ptit-report LaTeX template.

local stringify = pandoc.utils.stringify

local IMAGE_MAP = {
  ["erd/erd.svg"] = "erd/erd.pdf",
  ["erd/erd.png"] = "erd/erd.pdf",
  ["schema/schema.svg"] = "schema/schema.pdf",
  ["schema/schema.png"] = "schema/schema.pdf",
  ["schema/schema-v2.svg"] = "schema/schema-v2.pdf",
  ["schema/schema-v2.png"] = "schema/schema-v2.pdf",
}

local LANDSCAPE_FIGURES = {
  ["erd/erd.pdf"] = true,
  ["schema/schema.pdf"] = true,
  ["schema/schema-v2.pdf"] = true,
}

local function normalize_src(src)
  local clean = src:gsub("^%./", "")
  return IMAGE_MAP[clean] or clean
end

function Image(img)
  img.src = normalize_src(img.src)
  return img
end

-- Break long identifiers cleanly after '_', '.', '(', and spaces across body prose and tables.
local function append_breakable_text(text, target, split_spaces)
  local buf = {}
  local function flush()
    if #buf > 0 then
      target:insert(pandoc.Str(table.concat(buf)))
      buf = {}
    end
  end
  for i = 1, #text do
    local ch = text:sub(i, i)
    if ch == "_" then
      flush()
      target:insert(pandoc.RawInline("latex", "\\_\\allowbreak{}"))
    elseif ch == "(" or (ch == "." and text:sub(i + 1, i + 1):match("[A-Za-z_]")) then
      table.insert(buf, ch)
      flush()
      target:insert(pandoc.RawInline("latex", "\\allowbreak{}"))
    elseif split_spaces and ch == " " then
      flush()
      target:insert(pandoc.Space())
    else
      table.insert(buf, ch)
    end
  end
  flush()
end

function Code(c)
  local inlines = pandoc.List()
  inlines:insert(pandoc.RawInline("latex", "\\texttt{"))
  append_breakable_text(c.text, inlines, true)
  inlines:insert(pandoc.RawInline("latex", "}"))
  return inlines
end

local function make_inlines_breakable(inlines)
  local out = pandoc.List()
  for _, item in ipairs(inlines) do
    if item.t == "Str" and (item.text:find("_", 1, true) or item.text:find(".", 1, true) or item.text:find("(", 1, true)) then
      append_breakable_text(item.text, out, false)
    else
      out:insert(item)
    end
  end
  return out
end

function Para(p)
  p.content = make_inlines_breakable(p.content)
  return p
end

function Plain(p)
  p.content = make_inlines_breakable(p.content)
  return p
end

-- Strip manual numbering ("1. ", "1.1 ", "7.2.1 ") from headings so LaTeX secnumdepth numbers cleanly.
-- Also allow line breaks after underscores in headings without breaking PDF bookmarks.
function Header(h)
  if h.content and #h.content > 0 and h.content[1].t == "Str" then
    local txt = h.content[1].text
    if txt:match("^%d+[%.%d]*%.?$") and h.content[2] and h.content[2].t == "Space" then
      table.remove(h.content, 1)
      table.remove(h.content, 1)
    end
  end
  local out = pandoc.List()
  for _, item in ipairs(h.content) do
    if item.t == "Str" and item.text:find("_", 1, true) then
      local parts = {}
      for seg in (item.text .. "_"):gmatch("([^_]*)_") do
        table.insert(parts, seg)
      end
      for idx = 1, #parts do
        if idx > 1 then
          out:insert(pandoc.RawInline("latex", "\\texorpdfstring{\\_\\allowbreak{}}{_}"))
        end
        if parts[idx] ~= "" then
          out:insert(pandoc.Str(parts[idx]))
        end
      end
    else
      out:insert(item)
    end
  end
  h.content = out
  return h
end

function Table(tbl)
  local ncols = #tbl.colspecs
  if ncols == 4 then
    local widths = { 0.21, 0.25, 0.27, 0.27 }
    for i = 1, 4 do
      tbl.colspecs[i][2] = widths[i]
    end
  elseif ncols == 3 then
    local h1 = tbl.head and tbl.head.rows and tbl.head.rows[1]
      and tbl.head.rows[1].cells and tbl.head.rows[1].cells[1]
      and stringify(tbl.head.rows[1].cells[1].contents) or ""
    local widths = h1 == "Rule" and { 0.28, 0.14, 0.58 } or { 0.24, 0.16, 0.60 }
    for i = 1, 3 do
      tbl.colspecs[i][2] = widths[i]
    end
  elseif ncols == 2 then
    local widths = { 0.36, 0.64 }
    for i = 1, 2 do
      tbl.colspecs[i][2] = widths[i]
    end
  end
  return tbl
end

local function is_figure_caption_para(block)
  if block.t ~= "Para" then
    return false, nil
  end
  local text = stringify(block)
  local rest = text:match("^Figure%s+%d+:%s*(.+)$")
  if not rest then
    return false, nil
  end
  return true, rest
end

local function find_figure_image_src(fig)
  local src = nil
  pandoc.walk_block(fig, {
    Image = function(img)
      if not src then
        src = img.src
      end
    end,
  })
  return src
end

local function caption_to_latex(blocks)
  if not blocks or #blocks == 0 then
    return ""
  end
  local rendered = pandoc.write(pandoc.Pandoc(blocks), "latex")
  return (rendered:gsub("%s+$", ""))
end

function Pandoc(doc)
  local blocks = doc.blocks

  -- 1. Strip raw Markdown cover page block before first H1 chapter
  local out = pandoc.List()
  local in_body = false
  for _, b in ipairs(blocks) do
    if not in_body then
      if b.t == "Header" and b.level == 1 then
        in_body = true
        out:insert(b)
      end
    else
      out:insert(b)
    end
  end

  -- 2. Merge standalone Figure + immediately following "*Figure N: ...*" caption paragraph
  local merged = pandoc.List()
  local i = 1
  while i <= #out do
    local cur = out[i]
    local nxt = out[i + 1]
    if cur.t == "Figure" then
      local caption_blocks = cur.caption and cur.caption.long or {}
      local consumed_next = false
      if nxt then
        local ok, caption_text = is_figure_caption_para(nxt)
        if ok and caption_text then
          caption_blocks = { pandoc.Plain({ pandoc.Str(caption_text) }) }
          consumed_next = true
        end
      end

      local fig_src = find_figure_image_src(cur)
      if fig_src and LANDSCAPE_FIGURES[fig_src] then
        local cap_tex = caption_to_latex(caption_blocks)
        local step = consumed_next and 2 or 1
        local trailing_para = out[i + step]
        if trailing_para and trailing_para.t == "Para" then
          -- Place the overview paragraph before the landscape page break so chapter openers stay balanced.
          merged:insert(trailing_para)
          step = step + 1
        end
        merged:insert(pandoc.RawBlock("latex", string.format("\\landscapefigure{%s}{%s}", fig_src, cap_tex)))
        i = i + step
      else
        cur.caption = { long = caption_blocks }
        merged:insert(cur)
        i = i + (consumed_next and 2 or 1)
      end
    else
      merged:insert(cur)
      i = i + 1
    end
  end

  doc.blocks = merged
  return doc
end
