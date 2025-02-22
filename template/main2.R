# 处理日志文件
lapply(fs::dir_ls("logfile_blocks"), function(x){
  readLines(x) %>%
    paste0(collapse = "\n") %>%
    str_replace_all("///(\\s*)\n> ", "/// \n\\. ") %>%
    str_remove_all("\n> ") %>%
    str_split_1("\\n") %>%
    as_tibble() %>%
    filter(value != "" & value != ". " & value != ". log close") %>%
    mutate(value = if_else(str_detect(value, "^\\. "),
                           paste0(str_remove(value, "^\\. ")),
                           paste0("*> ", value))) %>%
    pull(value) %>%
    writeLines(x)
}) -> tempres

# 把 log 和图片重新写入新的 rmd 文件
for (i in 1:length(code_blocks)) { 
  asis_blocks <- ""
  picture_blocks <- ""
  logfile_blocks <- ""
  if (file.exists(paste0("asis_blocks/code_block", i, ".do"))) {
    asis_blocks <- paste0("```stata\n", str_trim(paste0(readLines(paste0("asis_blocks/code_block", i, ".do")), collapse = "\n")), "\n```")
  }
  if (file.exists(paste0("picture_blocks/temprstatadocpic", i, ".png"))) {
    picture_blocks <- paste0("![](", paste0("picture_blocks/temprstatadocpic", i, ".png"), ")")
  }
  if (!file.exists(paste0("asis_blocks/code_block", i, ".do"))) {
    logfile_blocks <- paste0("```stata\n", str_trim(paste0(readLines(paste0("logfile_blocks/temprstatadoclog", i, ".log")), collapse = "\n")), "\n```")
  }
  
  new_md_content <- str_replace(new_md_content, paste0("\\[\\[CODE_BLOCK_", i, "\\]\\]"), paste0(asis_blocks, "\n", logfile_blocks, "\n\n", picture_blocks))
}

# 保存成 Rmd 文件
writeLines(new_md_content, "new_md_content.Rmd")

# 编译成 html 文件
rmarkdown::render("new_md_content.Rmd")

