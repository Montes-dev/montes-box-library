MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.DataStructures = MB.Library.DataStructures or {}

function MB.Library.DataStructures.Initialize()
    MB.Library.Log("Data structures module initialized")
end

MB.Library.DataStructures.Queue = {
    New = function()
        return {
            _data = {},
            _first = 1,
            _last = 0,
            
            Push = function(self, value)
                self._last = self._last + 1
                self._data[self._last] = value
            end,
            
            Pop = function(self)
                if self._first > self._last then return nil end
                
                local value = self._data[self._first]
                self._data[self._first] = nil
                self._first = self._first + 1
                return value
            end,
            
            Size = function(self)
                return self._last - self._first + 1
            end,
            
            IsEmpty = function(self)
                return self._first > self._last
            end
        }
    end
}

hook.Add("MB.Library.Initialize", "MB.Library.DataStructures.Init", function()
    MB.Library.DataStructures.Initialize()
end) 