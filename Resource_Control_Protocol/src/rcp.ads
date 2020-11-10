package RCP is

   --  the amount of resources required by every single request
   --  can never exceed a predefined maximum quantity
   Max_Requests : constant Positive := 10;
   type Request_T is range 0 .. Max_Requests;

   type Use_T is (Long, Medium, Short);

   --  a descriptor type to denote the Item_T type and
   --  the assignment status of individual resources
   type Resource_T is record
      Item    : Use_T    := Long;
      Granted : Request_T := Request_T'First;
   end record;
end RCP;
