%Written by Chris Keeler, March 24th, 2015

% There are two types of decks for each player:
%      Regular Deck
%         (The deck from which a user draws to play a turn)
%      "Won cards" deck.
%         (The deck into which a user inserts their victorial cards)

card(w). % 0
card(b). % 1

cardVal(card(w),0).
cardVal(card(b),1).

player(p1).
player(p2).

%27 of each type of card comprise the deck
binaryDeck([
    card(w),card(w),card(w),card(w),card(w),
    card(w),card(w),card(w),card(w),card(w),
    card(w),card(w),card(w),card(w),card(w),
    card(w),card(w),card(w),card(w),card(w),
    card(w),card(w),card(w),card(w),card(w),
    card(w),card(w),
    card(b),card(b),card(b),card(b),card(b),
    card(b),card(b),card(b),card(b),card(b),
    card(b),card(b),card(b),card(b),card(b),
    card(b),card(b),card(b),card(b),card(b),
    card(b),card(b),card(b),card(b),card(b),
    card(b),card(b)]).

%black wins over white.
turnWinner(card(b),card(w)).
tie(card(b),card(b)).
tie(card(w),card(w)).

cardListSum([],0).
cardListSum([C|Cs],Total) :- cardVal(C,V), cardListSum(Cs,ValRest), Total = V+ValRest.



%%%%% BEGIN TURN-SWAP OPS %%%%%

% p1&p2 both emptied out, but still have "won cards". swap p1&p2's decks
turn([],[],[P1WonTop|P1WonRest], [P2WonTop|P2TopRest]) :- turn([P1WonTop|P1WonRest],[P2WonTop|P2TopRest],[],[]).

% p1 emptied out, but still has "won cards". swap p1's decks
turn([],A,[P1WonTop|P1WonRest],B) :- turn([P1WonTop|P1WonRest],A,[],B).

% p2 empties out, but still has "won cards". swap p2's decks
turn(A,[],B,[P2WonTop|P2WonRest]) :- turn(A,[P2WonTop|P2WonRest],B,[]).

%%%%% END TURN-SWAP OPS %%%%%



%%%%% BEGIN GAME-OVER TURN OPS %%%%%

% both players emptied out at the same time, but p1 has no "won cards"
turn([],[],[],[P2WonTop|P2WonRest],W) :- W = player(p2).

%both players empties out at the same time, but p2 has no "won cards"
turn([],[],[P1WonTop|P1WonRest],[],W) :- W = player(p1).

%p1 empties out and has no "won cards", but p2 still has cards
%this can occur if p2 has "won cards" or regular deck cards
turn([],[P2Top|P2Rest],[],P2Won,W) :- W = player(p2).
turn([],[],[],[P2WonTop|P2WonRest],W) :- W = player(p2).

%p2 empties out and has no "won cards", but p1 still has cards
%this can occur if p1 has "won cards" or regular deck cards
turn([P1Top|P1Rest],[],P1Won,[],W) :- W = player(p1).
turn([],[],[P1WonTop|P1WonRest],[],W) :- W = player(p1).

%%%%% END GAME-OVER TURN OPS %%%%%



%%%%% BEGIN WINNING TURN OPS %%%%%
% They are front appending and not shuffled after, to represent how the
% cards would become if one were to lay them face-up as they were placed
% into their "won cards deck". The first card to be played after the
% transfer from "won cards deck" to regular deck is the first card to be
% placed into the "won cards deck".

%p1 wins
turn([P1Top|P1Rest],[P2Top|P2Rest],P1Won,P2Won,W) :-
	print('p1 won; this time!'),
	turnWinner(P1Top,P2Top),
	turn(P1Rest,P2Rest,[P1Top,P2Top|P1Won],P2Won,W).

%p2 wins
turn([P1Top|P1Rest],[P2Top|P2Rest],P1Won,P2Won,W) :-
	print('p2 won; this time!'),
	turnWinner(P2Top,P1Top),
	turn(P1Rest,P2Rest,P1Won,[P1Top,P2Top|P2Won],W).

%%%%% END WINNING TURN OPS %%%%%



%%%%% BEGIN WAR-OPS %%%%%

%it's a tie! This means another battle in our war!
turn([P1Top|P1Rest],[P2Top|P2Rest],P1Won,P2Won,W) :-
	tie(P1Top,P2Top),
	war(P1Rest,P2Rest,P1Won,P2Won,P1NewD,P2NewD,P1NewW,P2NewW),
	turn(P1NewD,P2NewD,P1NewW,P2NewW,W).

% war(+P1Deck,+P2Deck,+P1Won,+P2Won,-P1NewDeck,-P2NewDeck,-P1NewWon,-P2NewWon)
%
% Input Parameters:
% P{1,2}Deck is a player's regular deck as they enter the war
% P{1,2}Won is a player's regular deck as they enter the war
%
% Output Parameters:
% P{1,2}NewDeck is a player's regular deck as they exit the war
% P{1,2}NewWon is a player's "won cards" deck as they exit the war
%
%During a war, a player's regular and "won cards" deck can change.
% The war(+A,+B,+C,+D,-E,-F,-G,-H) predicate determines the changes
% resulting from a war.
war(P1Deck,P2Deck,P1Won,P2Won,P1NewDeck,P2NewDeck,P1NewWon,P2NewWon) :-
	buildBattleHand(P1Deck,P2Deck,P1Won,P2Won,P1NewDeck,P2NewDeck,P1UpdatedWon,P2UpdatedWon,P1BH,P2BH,3),
	cardListSum(P1BH,P1V), cardListSum(P2BH,P2V),
        ((P1V > P2V,
	  print('p1 won a war'),
	  %add the cards from P2's battle hand to P1's "won cards" deck
	  append(P1UpdatedWon,P2BH,P1NewWon),
	  P2NewWon = P2UpdatedWon
	 ),
	 (P2V > P1V,
	  print('p2 won a war'),
	 %add the cards from P1's battle hand to P2's "won cards" deck
	  append(P2UpdatedWon,P1BH,P2NewWon),
	  P1NewWon = P1UpdatedWon
	 ),
	%If the values are equal, then we need to have another battle using the updated decks.
	 (P1V is P2V,
	  print('we have to go deeper!'),
	  war(P1NewDeck,P2NewDeck,P1UpdatedWon,P2UpdatedWon,P1DeeperDeck,P2DeeperDeck,P1DeeperWon,P2DeeperWon),
	  P1NewDeck=P1DeeperDeck,
	  P2NewDeck=P2DeeperDeck,
	  P1NewWon=P1DeeperWon,
	  P2NewWon=P2DeeperWon
	 )
	).

% buildBattleHand(+P1Deck,+P2Deck,+P1Won,+P2Won,-P1DRem,-P2DRem,-P1WRem,-P2WRem,-P1BH,-P2BH,+CardsLeft)
% Input Parameters:
% P{1,2}Deck is a player's regular deck as they enter the construction
%   of their battle hand
% P{1,2}Won is a player's "won cards" deck as they enter the
%   construction of their battle hand
% CardsLeft is how many cards are left to be added to the battle hands.
%
% Output parameters
% P{1,2}DRem is a player's regular deck as they exit the war
% P{1,2}WRem is a player's "won cards" deck as they exit the war
% P{1,2}BH is a player's battle hand as they exit the war

% There is no more room to add a card to battle hands.
% At this point, we save the state of the regular deck after additions
% to the battle hand
buildBattleHand(P1Deck,P2Deck,P1Won,P2Won,P1Remaining,P2Remaining,P1WRem,P2WRem,P1BH,P2BH,0) :- P1BH = [], P2BH = [], P1Remaining = P1Deck, P2Remaining = P2Deck, P1WRem=P1Won, P1WRem=P2Won.
%It is important that this definition come first so that
% we know for future calls of buildBattleHand(A,B,C,D,E,F,G,H,I) that
% I>0.



%%%%% BEGIN WAR-SWAP OPS %%%%%
% It is important that these definitions for
% buildBattleHand(A,B,C,D,E,F,G,H,I) occur here, as it will always swap
% a player's "won deck" into their regular deck, so long as they have
% one and there are still cards which can be added

% p1 has run out of regular cards, but still has "won cards" from before
buildBattleHand([],P2Deck,[P1WonTop|P1WonRest],P2Won,P1DRem,P2DRem,P1WRem,P2Wrem,P1BH,P2BH,CardsLeft) :- buildBattleHand([P1WonTop|P1WonRest],P2Deck,[],P2Won,P1DRem,P2DRem,P1WRem,P2Wrem,P1BH,P2BH,CardsLeft).

%p2 has run out of regular cards, but still has "won cards" from before
buildBattleHand(P1Deck,[],P1Won,[P2WonTop|P2WonRest],P1DRem,P2DRem,P1WRem,P2WRem,P1BH,P2BH,CardsLeft) :- buildBattleHand(P1Deck,[P2WonTop|P2WonRest],P1Won,[],P1DRem,P2DRem,P1WRem,P2WRem,P1BH,P2BH,CardsLeft).

%%%%% END WAR-SWAP OPS %%%%%



%%%%% BEGIN HAND-ADD OPS %%%%%

%p1 has run out of regular cards, and has no "won cards" from before
%we let p2 keep adding cards, so long as they have them.
buildBattleHand([],[P2Top|P2Rest],[],P2Won,P1DRem,P2DRem,P1WRem,P2WRem,P1BH,P2BH,CardsLeft) :- buildBattleHand([],P2Rest,[],P2Won,P1DRem,P2DRem,P1WRem,P2WRem,P1BH,P2BHRest,CardsLeft-1), P2BH = [P2Top|P2BHRest].

%p2 has run out of regular cards, and has no "won cards" from before.
%we let p1 keep adding cards, so long as they have them
buildBattleHand([P1Top|P1Rest],[],P1Won,[],P1DRem,P2DRem,P1WRem,P2WRem,P1BH,P2BH,CardsLeft) :- buildBattleHand(P1Rest,[],P1Won,[],P1DRem,P2DRem,P1WRem,P2WRem,P1BHRest,P2BH,CardsLeft-1), P1BH = [P1Top|P1BHRest].

% the cases where p1 or p2 has run out of regular cards but still has
% "won cards" from before is covered by the WAR-SWAP OPS above

% both players have a card to add to their battle hand, and there's
% still room to add a card to the battle hand
buildBattleHand([P1Top|P1Rest],[P2Top|P2Rest],P1Won,P2Won,P1DRem,P2DRem,P1WRem,P2WRem,P1BH,P2BH,CardsLeft) :- buildBattleHand(P1Rest,P2Rest,P1Won,P2Won,P1DRem,P2DRem,P1WRem,P2WRem,P1BHRest,P2BHRest,CardsLeft-1), P1BH = [P1Top|P1BHRest], P2BH = [P2Top|P2BHRest].

%%%%% END HAND-ADD OPS %%%%%
