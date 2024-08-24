/*
📓 Non-Loaded Data is Easy, Let's Do Some More!
For the metadata files, we created file formats and then used those file formats when we created views. It was pretty easy, right? 

Remember that Zena (and you) started by creating two Stage objects that you uploaded files into.

Zena then focused her efforts on one of those stages - the PRODUCT_METADATA stage - that happens to contain only STRUCTURED data files. She learned to use FILE FORMATS and VIEWS to make the files very accessible without even loading her data into a Snowflake table!  

Zena has another other Stage objects she set up. Next, she wants to use her SWEATSUITS stage, however, that stage contains images.

Images are considered UNSTRUCTURED data, so she's wondering if accessing images without loading them will be just as easy as the flat files. 

Zena's not sure but she'll give it a try!

🎯 Run a List Command On the SWEATSUITS Stage
Run a LIST command on the SWEATSUITS Stage you created.

What do you see? 
*/
list @zenas_athleisure_db.products.SWEATSUITS;