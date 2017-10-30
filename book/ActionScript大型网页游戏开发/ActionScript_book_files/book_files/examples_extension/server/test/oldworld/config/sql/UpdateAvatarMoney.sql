-- Used to update the avatar's bottom
update
    avatar
set
    money = :money
where
    id = :avatarId