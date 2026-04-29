classdef Renege < Event
    % Departure Subclass of Event that represents the departure of a
    % Customer.

    properties
        % ServerIndex - Index of the service station from which the
        % departure occurred
   
        Id;
    end
    methods
        function obj = Renege(Id, RenegeTime)
            % Departure - Construct a departure event from a time and
            % server index.
            arguments
                Id = 0;
                RenegeTime = 0.0;
            end
            
            % MATLAB-ism: This incantation is how to invoke the superclass
            % constructor.
            obj = obj@Event(RenegeTime);
            obj.Id = Id;

        end
        function varargout = visit(obj, other)
          

            % MATLAB-ism: This incantation means whatever is returned by
            % the call to handle_departure is returned by this visit
            % method.
            [varargout{1:nargout}] = handle_renege(other, obj);
        end
    end
end