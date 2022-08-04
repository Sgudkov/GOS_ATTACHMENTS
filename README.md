# GOS_ATTACHMENTS
## Get all attachmetns of bussines objects

### This example show how you can retrieve all attachmetns of any bussines object.

#### How use.

1. Run method *SET_OBJECT*. This method define what kind of attachmetns do you want to retrieve.
> ATTACHMENTS - retrieve all attachmetns of BO.
  NOTES - retrieve all notes of BO.
  URLS - retrieve all urls of BO.

*Want to get all urls of BO FMBU*
```abap  
  ls_object-objkey  = '0400000004'.
  ls_object-objtype = 'FMBU'.
  ls_object-urls    = 'X'.
```  

2. Run method *GET_ATTACHMENTS* to retrieve all uploaded data for BO for those attachments which you selected in step 1.

> This is what method returned

![alt text](https://github.com/Sgudkov/GOS_ATTACHMENTS/blob/main/attachments_main.jpg)