with Ada.Finalization;

package SoE is

   --  process Odd will be activated as part of the elaboration
   --  of the enclosing package
   -----------------------------------
   task Odd is
      --  we want the user to set the limit of the search range
      entry Set_Limit (User_Limit : Positive);
   end Odd;

   -----------------------------------
   task type Sieve_T (Id : Positive) is
      entry Relay (Int : Positive);
   end Sieve_T;
   type Sieve_Ref is access Sieve_T;

   --  for terminating processes to express last wishes
   --  we need to place explicitly finalizable objects
   --  within the scope of tasks that may be finalized:
   --  in this way, the task finalization will first require finalization
   --  of all objects in its scope, which will occur by automatic
   --  invocation of the method Finalize on each such object
   -----------------------------------
   type Last_Wishes_T is new Ada.Finalization.Limited_Controlled with
      record
         Id : Positive;
      end record;
   procedure Finalize (Last_Wishes : in out Last_Wishes_T);
   --  the type of finalizable objects must be an extension of this
   --  special type of the language
   -----------------------------------

end SoE;
