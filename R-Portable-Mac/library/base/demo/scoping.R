
## Here is a little example which shows a fundamental difference between
## R and S.  It is a little example from Abelson and Sussman which models
## the way in which bank accounts work.	It shows how R functions can
## encapsulate state information.
##
## When invoked, "open.account" defines and returns three functions
## in a list.  Because the variable "total" exists in the environment
## where these functions are defined they have access to its value.
## This is even true when "open.account" has returned.  The only way
## to access the value of "total" is through the accessor functions
## withdraw, deposit and balance.  Separate accounts maintain their
## own balances.
##
## This is a very nifty way of creating "closures" and a little thought
## will show you that there are many ways of using this in statistics.

#  Copyright (C) 1997-8 The R Core Team

open.account <- function(total) {

    list(
	 deposit = function(amount) {
	     if(amount <= 0)
		 stop("Deposits must be positive!\n")
	     total <<- total + amount
	     cat(amount,"deposited. Your balance is", total, "\n\n")
	 },
	 withdraw = function(amount) {
	     if(amount > total)
		 stop("You don't have that much money!\n")
	     total <<- total - amount
	     cat(amount,"withdrawn.  Your balance is", total, "\n\n")
	 },
	 balance = function() {
	     cat("Your balance is", total, "\n\n")
	 }
	 )
}

ross <- open.account(100)
robert <- open.account(200)

ross$withdraw(30)
ross$balance()
robert$balance()

ross$deposit(50)
ross$balance()
try(ross$withdraw(500)) # no way..
