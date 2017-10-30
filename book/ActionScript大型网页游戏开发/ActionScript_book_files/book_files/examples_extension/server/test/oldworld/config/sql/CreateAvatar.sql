-- Creates an avatar
insert into avatar
(name, pword, money, gender, hairstyle, clothingtop, clothingbottom, shoes)
values
(:username, :password, :money, :gender, :hairstyle, :top, :bottom, :shoes)