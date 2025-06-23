## Comparison of Build Time With and Without Source Downloads

An experiment was conducted: the `core_image_minimal` image was built twice.  
- The first build was done **without** downloading sources and took about **33 minutes**.  
- The second time, the `/build/downloads` folder was deleted – the build **included downloading sources** and took about **40 minutes**.  

Thus, the build without source downloads was approximately **17.5% faster**.

Log files: https://drive.google.com/drive/folders/1xsnJvBOW3qCXUo7xwkD7bQgPpuamurJ8?usp=drive_link
