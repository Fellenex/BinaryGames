Game description acquired from:
<br>
   https://github.com/toruurakawa/Encyclopedia-of-Binary-Card-Games/blob/master/Games/War.md
<br><br>
*Original Problem-Domain Description:*
<br>
**1.** Players play the top card from their deck at the same time laying them on the table from right to left.
<br>
**2.** If less than 3 players are playing they should lay down five cards to start.
<br>
**3.** If there are 3 or more players you should lay down three cards to start.
<br>
**4.** 1 (black) beats 0 (white); the player who plays the black card takes both
<br>
**5.** If the players play the same card, they place the next 3 cards faceup; the sum of those cards decides the winner.
<br>
**6.** Players keep playing until their deck is empty; at that point they take all the cards that they won; this becomes their new deck.
<br>
**7.** Gameplay continues until 1 player has all the cards
<br><br>
*Updated Problem-Domain Descriptions:*
**5.** If the players play the same card, they initiate a "battle" by creating a "battle hand" of up to 3 cards; the sum of those cards decides the winner. In the event that the sum of a battle is the same for both players, then another "battle" is initiated. The winner of the final battle takes all of the cards used in all of the battles up to and including the final one.
<br>
**5.2** In the event that a player runs out of cards in their regular deck while adding cards to their battle hand, they swap their "won cards" deck and their regular deck and continues to add cards to their battle hand.
<br>
**5.4** In the event that a player runs out of cards in their regular deck and their "won cards" deck, that player's battle hand sum is already decided. The other player is allowed to continue adding cards to their battle hand until they have 3. The winner of the battle is determined normally, with the possibility of one player having more cards than the other.


**TODO:**
<br>
*Seed a game by randomizing and splitting the deck up*
<br>
*Print statements to trace the pathing of the game*
<br>
*Split binary deck and game definitions into different files*
