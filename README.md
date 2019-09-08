##### This project is a Pacman-adapted game used for survey on Coverage Path Planning problem

##### See Examples in "pictures" folder 



080919 update: when the Pacman has a large Size( >1), it can collect all the coins it cover and **don't collect ones hidden by the wall**

060919 update: Enlarge the Pacman's Size and let it be able to eat all the coins it cover instead of the only one on its position





WriteCoin.m					  ->>>Write the Coin information into the coin.txt and temporarily useless

pacmanAI.m					  ->>>Agent is temporarily not created

pacman.m  				   	->>> main function

MapConfiguration.m		->>>a development program, all of codes inside are integrated to the pacman.m

map.m								->>>Map configuration

ifconnected.m 				  ->>>Judge if the grids between two points is free (not occupied)

getDirMap.m					 ->>>get the Direction Map	

deletecoin.m					 ->>>delete coins when path through the coins







Created by Songqun Gao Aug,27,2019

Adapted from Programmer Markus Petershofen
