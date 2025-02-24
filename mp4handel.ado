*! mp4handel: 自动给视频添加水印及生成前 20 分钟的预览视频
*! 微信公众号 RStata 
capture program drop mp4handel
program define mp4handel, rclass 
	syntax anything(name = mp4file) [, wmpic(string)]
	cap preserve 
	if "`wmpic'" == "" {
		local wmpic = "/Users/ac/Documents/rstata.png"
	}
	local name = subinstr(`mp4file', ".mp4", "", .)
	!/opt/homebrew/bin/ffmpeg -i "`mp4file'" -vf "movie=`wmpic',scale=202:335[watermark];[in][watermark] overlay=main_w-overlay_w-5:5" "watermarked_`mp4file'"
	!/opt/homebrew/bin/ffmpeg -i "watermarked_`mp4file'" -ss 00:00:00 -t 00:20:00 -c copy "preview_`mp4file'"
	di "`name'"
	di "RStata 培训班试听课，更多内容欢迎报名 RStata 培训班学习，然后课程学习中遇到的问题都可以随时提问～"
end 
