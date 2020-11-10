package RCP.User is

   --  a user process class with discriminants
   --  for use by the constructor
   task type User_T
     (Id       : Positive;
      Extent   : Use_T;
      Demand   : Request_T;
      Interval : Positive);

end RCP.User;
