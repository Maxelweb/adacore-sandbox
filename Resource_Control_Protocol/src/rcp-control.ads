package RCP.Control is

   protected Controller is
      entry Demand
        (Res :    out Resource_T;
         Req :        Request_T);
      procedure Release (Res : Resource_T);
      function Query return Request_T;
   private
      --  we use a private typed channel
      --  not visibile from the outside of this object
      --  COMPATIBLE with Demand
      entry Assign
        (Res :    out Resource_T;
         Req :        Request_T);

      --  initially all resourses are free
      Free        : Request_T := Request_T'Last;

      --  the lowest unsatisfied request
      --  used to condition the opening of the guard to Assign
      Min_Request : Request_T := Request_T'Last;

      --  this Boolean tells us whether there
      --  are pending requests while there are
      --  some, but not enough, resources
      Available   : Boolean := False;

      --  this counter tells us how may pending
      --  requests we have at present
      Considered  : Natural := 0;
   end Controller;

end RCP.Control;
