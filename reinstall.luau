local cloneref = cloneref or function(ref: any)
    return ref
end

if isfolder('neptune') then
    delfolder('neptune')
end

cloneref(game:GetService('StarterGui')):SetCore('SendNotification', {
    Title = 'Neptune',
    Text = 'Successfully reinstalled Neptune, Please rejoin ur game to take effect',
    Duration = 20
})