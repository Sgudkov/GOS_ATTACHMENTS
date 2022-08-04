# GOS_ATTACHMENTS
## Get all attachmetns of bussines objects

### This example show how you can retrieve all attachments of any bussines object.

#### How use.

1. Run method *SET_OBJECT*. This method define what kind of attachmetns do you want to retrieve.
> ATTACHMENTS - retrieve all attachmetns of BO.
  NOTES - retrieve all notes of BO.
  URLS - retrieve all urls of BO.

*Want to get all urls of BO FMBU*
```abap  
  DATA: lo_attachments TYPE REF TO lcl_gos_attachments,
		lt_attachmetns TYPE lcl_gos_attachments=>mty_t_borid.
		
  CREATE OBJECT lo_attachments.	
  
  ls_object-objkey  = '0400000004'.
  ls_object-objtype = 'FMBU'.
  ls_object-urls    = 'X'.

  lo_attachments->set_object(
   EXPORTING
     is_object = ls_object
   ).  
```  

2. Run method *GET_ATTACHMENTS* to retrieve all uploaded data for BO for those attachments which you selected in step 1.

*Get requested attachments*
```abap 
  lt_attachmetns = lo_attachments->get_attachments( ).
``` 
   
> This is what method returned

![alt text](https://github.com/Sgudkov/GOS_ATTACHMENTS/blob/main/attachments_main.jpg)

Table has field with table type where store all attachments which are represented like instance of class *CL_MSG_AL_ITEM*.

![alt text](https://github.com/Sgudkov/GOS_ATTACHMENTS/blob/main/attachments_bitem.jpg)

