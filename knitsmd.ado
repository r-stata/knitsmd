*! 编译 RStata Markdown 文件
*! 微信公众号 RStata 
*! keeppic：是否保留生成的 pic 文件。
capture program drop knitsmd
program define knitsmd, rclass 
	syntax anything(name = smdfile) [, keeppic]
	cap preserve 
	clear all 
	rcall: rstatacreator::code_split(`smdfile')
	do temp_smd_dofile.do
	if "`keeppic'" != "" {
		rcall: rstatacreator::logfile_handel(`smdfile', delete_pic = F)
	}
	if "`keeppic'" == "" {
		rcall: rstatacreator::logfile_handel(`smdfile', delete_pic = T)
	}
end
