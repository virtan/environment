# (c) 2014+ virtan virtan@virtan.com
 
# Variables

OS=$(shell uname -s | tr '[:upper:]' '[:lower:]')
BYROOT=$(shell test `id -u` -eq 0 && echo || which sudo || echo "su root -c")
CLICLICK=$(shell which cliclick || echo install-cliclick-$(OS))
CURL=$(shell which curl || echo install-curl-$(OS))
GIT=$(shell which git || echo install-git-$(OS))
ERL=$(shell which erl || echo install-erlang-$(OS))
 
# Targets

translate: $(CURL)
	@while true ; do \
	    read -p "Phrase: " INPUT && \
	    if [ -z "$$INPUT" ] ; then exit 0 ; \
	    elif /bin/echo $$INPUT | grep -qe "^[ -~]*$$" ; then \
	    /bin/echo -n "Result: " ; curl -s -i --user-agent "" -d "sl=en" -d "tl=ru" --data-urlencode "text=$$INPUT" https://translate.google.com | iconv -f cp1251 -t utf-8 | sed -n "s/^.*TRANSLATED_TEXT=\'\([^\']*\)\'.*$$/\\1/p" ; \
	    else \
	    /bin/echo -n "Result: " ; curl -s -i --user-agent "" -d "sl=ru" -d "tl=en" --data-urlencode "text=$$INPUT" https://translate.google.com | iconv -f cp1251 -t utf-8 | sed -n "s/^.*TRANSLATED_TEXT=\'\([^\']*\)\'.*$$/\\1/p" ; \
	    fi ; \
	    done

work: enable_pf $(CLICLICK)
	date "+%s working" >> ~/.working_history
	make block-entertainment
	cliclick -r -m verbose -w 1000 m:1370,1 kd:alt c:1370,1

block-entertainment: block-ip-www.facebook.com block-ip-d3.ru block-ip-top.rbc.ru \
    		     block-ip-www.quora.com block-ip-api.twitter.com

unblock-entertainment:
	$(BYROOT) pfctl -t blockedips -T flush 2>/dev/null

relax: enable_pf $(CLICLICK)
	date "+%s relaxing" >> ~/.working_history
	make unblock-entertainment
	cliclick -r -m verbose -w 1000 m:1370,1 kd:alt c:1370,1


# Tools

enable_pf:
	@fgrep -q "block drop out quick on en0 inet from any to <blockedips>" /etc/pf.conf || \
	    ( echo "block drop out quick on en0 inet from any to <blockedips>" | \
	    $(BYROOT) tee -a /etc/pf.conf ; \
	    $(BYROOT) pfctl -f /etc/pf.conf )
	-@$(BYROOT) pfctl -e 2>/dev/null

block-ip-%:
	host -t a $* | sed -n "s/^.*has address \([0-9.]*\)/\\1/p" | xargs -n 1 -I% \
	    $(BYROOT) pfctl -t blockedips -T add % 2>/dev/null

install-%-darwin:
	$(BYROOT) port install $* || \
	$(BYROOT) brew install $* || \
	( echo "Please, install $*" ; false )

install-%-linux:
	$(BYROOT) apt-get install $* || \
	$(BYROOT) yum install $* || \
	( echo "Please, install $*" ; false )

install-%:
	( echo "Please, install $*" | sed "s/-[a-z0-9]*$$//" ; false )


# System

.PHONY: translate work relax enable_pf block-entertainment unblock-entertainment


# Templates


