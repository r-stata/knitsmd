# 加载必要的包
library(stringr)

# 读取 Markdown 文件
md_file_path <- "main.md"  # 替换为你的 Markdown 文件路径
md_content <- readLines(md_file_path)

# 提取代码块
code_blocks <- str_extract_all(paste(md_content, collapse = "\n"), "```[\\s\\S]*?```")[[1]]

code_blocks[1] 

# 创建目录保存代码运行日志
output_dir <- "logfile_blocks"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
} 

# 创建图片目录保存代码块
picture_dir <- "picture_blocks"
if (!dir.exists(picture_dir)) {
  dir.create(picture_dir)
} 

# 创建目录保存 "asis" 代码块
asis_dir <- "asis_blocks"
if (!dir.exists(asis_dir)) {
  dir.create(asis_dir)
} 

# 去除不想要执行的代码
code_blocks[str_detect(code_blocks, "\\{stata")] -> code_blocks 

code_blocks

# 代码编号
code_blocks %>% 
  as_tibble() %>% 
  mutate(rawid = row_number(), 
         id = paste0("\n\n*- [[CODE_BLOCK_", row_number(), "]]")) %>% 
  select(rawid, id, everything()) -> code_blocksdf 

code_blocksdf

# asis 代码块单独保存
code_blocksdf %>% 
  filter(str_detect(value, "\\{stata asis\\}")) %>% 
  mutate(value = str_remove_all(value, "```|\\{stata asis\\}(\\s*)\n")) %>% 
  mutate(res = map2(rawid, value, ~writeLines(.y, paste0(asis_dir, "/code_block", .x, ".do")))) -> tempres 

# asis 代码块单独保存
# 去除代码块标记
code_blocksdf %>% 
  mutate(value = str_remove_all(value, "```|\\{stata\\}|\\{stata asis\\}"),
         value = paste0("set linesize 80\ncap graph close\ncap log close\nlog using logfile_blocks/temprstatadoclog", row_number(), ", replace text nomsg\n", value, "\nlog close\ncap graph export picture_blocks/temprstatadocpic", row_number(), ".png, replace width(4800)"),
         value = paste0(id, "\n", value)) %>% 
  pull(value) %>% 
  writeLines("temp_rstata_dofile.do")

# 生成新文件，替换代码块为特殊编号
new_md_content <- paste0(md_content, collapse = "\n")
for (i in seq_along(code_blocks)) {
  code_block <- code_blocks[i]
  new_md_content <- str_replace_all(new_md_content, stringr::fixed(code_block), paste0("[[CODE_BLOCK_", i, "]]"))
}

