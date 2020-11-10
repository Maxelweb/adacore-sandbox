with Ada.Text_IO;
package body RCP.Control is

   protected body Controller is
      entry Demand
        (Res : out Resource_T;
         Req :        Request_T) when Free > 0 is
         --  we accept the request if we have spare resources to offer
      begin
         --  but we satisfy it ONLY if have enough for it
         if Req <= Free then
            --  the lucky user has got all the items
            --  that it wanted the first time round!
            Res.Granted := Req;
            Free := Free - Req;
         else
            --  otherwise we transfer the request to an internal queue
            --  after keeping record of the smallest request that
            --  we were unable to satisfy
            --  (this value will help us update the guard to
            --   the private channel Assign)
            if Req < Min_Request then
               Min_Request := Req;
            end if;
            --  with this statement we transfer the current request
            --  to the queue of the private channel Assign
            --  (the transfer is executed directly,
            --   WITHOUT evaluating the guard associated to Assign
            --   because the target is the queue, NOT the channel itself)
            requeue Assign;
            --  try and see what would happen if we used an EXTERNAL requeue
            --  to the same target:
            --  requeue Controller.Assign;
         end if;
      end Demand;

      -------------

      entry Assign
        (Res : out Resource_T;
         Req : Request_T) when Available is
         --  users will enter this service only if there are
         --  enough spare resources (Available = True)
         --  AND those users had previously been denied service
         --+---------
         --  THE PROTOCOL ASSUMES (and requires) FIFO QUEUEING
      begin
         --  one less request in queue
         Considered := Considered - 1;
         --  was this call the last one in the Assign queue?
         if Considered = 0 then
            --  then we close the guard to this channel
            Available := False;
            --  at this point we should update Min_Request!
         end if;
         --  can we now satisfy this request?
         if Req <= Free then
            --  yes, this requeued user can now be granted
            --  what it initially wanted
            Res.Granted := Req;
            Free := Free - Req;
         else
            --  otherwise we must requeue the unlucky user
            --  again and update the record of the smallest
            --  pending request
            if Req < Min_Request then
               Min_Request := Req;
            end if;
            requeue Assign;
            --  try and see what would happen if we used an EXTERNAL requeue
            --  to the same target:
            --  requeue Controller.Assign;
         end if;
      end Assign;

      -------------

      procedure Release (Res : Resource_T) is
      begin
         --  this service is executed when a user
         --  returns its allocation of resources
         Free := Free + Res.Granted;
         --  as the level of reserve has now increased
         --  we should take a look at the requests that
         --  are awaiting in the Assign queue
         if Free > Min_Request and then Assign'Count > 0 then
            --  since we do NOT know which user placed the smallest demand
            --  we simply take note of the number of requests
            --  currently enqueued at Assign and open the guard to it
            --  ===> IS THIS CLEVER? <===
            Considered := Assign'Count;
            Available := True;
            --  and finally we reset the value of Min_Request
            --  so that it may be recomputed by the execution of Assign
            Min_Request := Request_T'Last;
         end if;
      end Release;

      function Query return Request_T is
      begin
         return Free;
      end Query;

   end Controller;
   -------------------------
begin
   Ada.Text_IO.Put_Line
     ("The system starts with "
      & RCP.Control.Controller.Query'Img
      & " free resources");
   Ada.Text_IO.Put_Line
     ("-----+---------+------------+--------");
   Ada.Text_IO.Put_Line
     ("User | Request | Allocation | Release");
   Ada.Text_IO.Put_Line
     ("-----+---------+------------+--------");
end RCP.Control;
