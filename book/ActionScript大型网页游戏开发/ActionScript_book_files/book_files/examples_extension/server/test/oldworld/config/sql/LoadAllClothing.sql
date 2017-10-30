-- Used to load everything from the clothing table at application start up
select
    id,
    clothingtype,
    name,
    filename,
    cost
from
    clothing