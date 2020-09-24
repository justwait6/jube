local EventCenter = {}
EventCenter._listeners = {}

-- eventName:string, func:function, tag:anything
function EventCenter:on(eventName, func, tag)
    assert(tag, "Tag must not be nil")
    local listeners = EventCenter._listeners
    if not listeners[eventName] then
        listeners[eventName] = {}
    end
    
    local eventListeners = listeners[eventName]
    for i = 1, #eventListeners do
        if tag == eventListeners[i][2] then
            -- avoid repeate add listener for a tag
            return
        end
    end
    table.insert(eventListeners, {func, tag})
end

function EventCenter:remove(func)
    local listeners = EventCenter._listeners
    for eventName, eventListeners in pairs(listeners) do
        for i = 1, #eventListeners do
            if eventListeners[i][1] == func then
                -- remove listener
                table.remove(eventListeners, i)
                -- clear table
                if 0 == #listeners[eventName] then
                    listeners[eventName] = nil
                end
                return
            end
        end
    end
end

function EventCenter:removeByNameAndTag(eventName, tag)
    assert(tag, "Tag must not be nil")
    local listeners = EventCenter._listeners
    local eventListeners = listeners[eventName]
    if not eventListeners then return end

    for i = #eventListeners, 1, -1 do
        if eventListeners[i][2] == tag then
            -- remove listener
            table.remove(eventListeners, i)
            break
        end
    end
    -- clear table
    if 0 == #eventListeners then
        listeners[eventName] = nil
    end
end

function EventCenter:removeByTag(tag)
    assert(tag, "Tag must not be nil")
    local listeners = EventCenter._listeners
    for eventName, eventListeners in pairs(listeners) do
        EventCenter:removeByNameAndTag(eventName, tag)
    end
end

function EventCenter:removeAll()
    EventCenter._listeners = {}
end

function EventCenter:emit(eventName, ...)
    local listeners = EventCenter._listeners
    local eventListeners = listeners[eventName]
    if not eventListeners then
        return
    end

    -- keep register order to send message
    local tmp = {}
    for index, listeners in ipairs(eventListeners) do
        -- copy table to avoid listener remove in deal func
        tmp[index] = listeners
    end
    for _, listeners in ipairs(tmp) do
        listeners[1](...)
    end
end

return EventCenter
