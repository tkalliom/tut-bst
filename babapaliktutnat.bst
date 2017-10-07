%%
%% This is file `bababbrtut.bst',
%% based on the files `bababbrv-lf.bst' v1.31 by Harald Hardeds and
%% `abbrvnat-bst' v1.93 by Patrick W Daly
%%
%%   This program can be redistributed and/or modified under the terms
%%   of the LaTeX Project Public License Distributed from CTAN
%%   archives in directory macros/latex/base/lppl.txt; either
%%   version 1 of the License, or any later version.
%% 
%% 2017/10/07 v0.95d

% 0.95d: Correct French and Swedish jvolume, fix extra space before note which was messing with hyphenation

ENTRY
  { address
    annote
    annotelanguage
    author
    booktitle
    chapter
    edition
    editor
    howpublished
    institution
    isbn
    issn
    journal
    key
    language
    location %% Bibtex defines 'address' as where event was held for proceedings, so this needs to be borrowed from biblatex for publisher
    month %% Strictly taken this should always be for publication month, but it is established practice to place conference dates here, like 'dec # "5--9"'
    note
    numappendixpages %% There seems to be no suitable existing field name for this
    number
    numpages %% sees more usage than biblatex-defined pagetotal (numpages/pagetotal filetype:bst gives 8000 vs. 500 Google hits)
    organization
    pages
    pagetotal %% for compatibility with biblatex
    publisher
    school
    series
    title
    type
    url
    urldate
    venue %% for compatibility with biblatex
    volume
    year
  }
  {}
  { label extra.label sort.label short.list }

INTEGERS
  { output.state
    before.all
    mid.sentence
    after.sentence
    after.block
    before.year
    before.incollection.in
  }

STRINGS
  { s
    t
    language.state
    change.temp
    isbn.command
  }

FUNCTION {init.state.consts}
{ #0 'before.all :=
  #1 'mid.sentence :=
  #2 'after.sentence :=
  #3 'after.block :=
  #4 'before.year :=
  #5 'before.incollection.in :=
  "nostate" 'language.state :=
}

FUNCTION {not}
{   { #0 }
    { #1 }
  if$
}

FUNCTION {and}
{   'skip$
    { pop$ #0 }
  if$
}

FUNCTION {or}
{   { pop$ #1 }
    'skip$
  if$
}

FUNCTION {language.change.case}
{
  'change.temp :=
  't :=
  "\btxifchangecase {"
  t change.temp change.case$ *
  "}{" *
  t *
  "}" *
}

FUNCTION {output.nonnull}
{ 's :=
  output.state mid.sentence =
    { ", " * write$ }
    { output.state after.block =
        { add.period$ write$
          newline$
          "\newblock " write$
        }
        { output.state before.all =
            'write$
            {
              output.state before.year =
              output.state before.incollection.in =
              or
                { " " * write$ }
                { add.period$ " " * write$ }
              if$
            }
          if$
        }
      if$
      mid.sentence 'output.state :=
    }
  if$
  s
}

FUNCTION {output}
{ duplicate$ empty$
    'pop$
    'output.nonnull
  if$
}

FUNCTION {output.check}
{ 't :=
  duplicate$ empty$
    { pop$ "empty " t * " in " * cite$ * warning$ }
    'output.nonnull
  if$
}

% Entries with ISBN defined could potentially cause problems at the end of the entry.
% Consider entries with endings like ", 2007, 315 p.\ifbtxprintisbn{978-...-0}" and ", 2015 \ifbtxprintisbn{1234-5678}". Even if the flag is off, the add.period$ command considers the last character to be 0/8 - causing the entry to end like ", 2007, 315p.."
% If we were to print a period here, then the latter entry would be missing a period when ISBN printing is not on.
% The bibliography style does not include ISBNs anyway, so let's just arbitrarily move the ISBNs a bit upward in the entry types where they might cause problems
FUNCTION {output.isbn}
{
  'isbn.command :=
  duplicate$
  empty$
    'pop$
    {
      's :=
      output.state mid.sentence =
        {
          isbn.command * " {, " * write$
          s "}" *
        }
        { output.state after.block =
            {
              add.period$
              write$
              newline$
              "\newblock " write$
              isbn.command " {" * s * ".}" *
            }
            { output.state before.all =
                {
                  write$
                  isbn.command " {" * write$
                  s "}" *
                }
                {
                  output.state before.year =
                    {
                      "\btxauthorcolon\ " * write$
                      isbn.command " {" * write$
                      s "}" *
                    }
                    {
                      add.period$ " " * write$
                      isbn.command " {" * write$
                      s ".}" *
                    }
                  if$
                }
              if$
            }
          if$
          mid.sentence 'output.state :=
        }
      if$
    }
  if$
}

FUNCTION {fin.entry}
{ % we don't want periods for entries ending in URLs, so let's do the period adding in each entry before the URL
  write$
  newline$
}

FUNCTION {new.block}
{ output.state before.all =
    'skip$
    { after.block 'output.state := }
  if$
}

FUNCTION {new.sentence}
{ output.state after.block =
    'skip$
    { output.state before.all =
        'skip$
        { after.sentence 'output.state := }
      if$
    }
  if$
}

% May also be "after title" if there is no author
FUNCTION {after.authors}
{ output.state before.all =
    'skip$
    { before.year 'output.state := }
  if$
}

FUNCTION {after.incollection.chapter}
{ output.state before.all =
    'skip$
    { before.incollection.in 'output.state := }
  if$
}

FUNCTION {new.block.checka}
{ empty$
    'skip$
    'new.block
  if$
}

FUNCTION {new.block.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.block
  if$
}

FUNCTION {new.block.checkc}
{ empty$
  swap$ empty$
  and
    'skip$
    'after.authors
  if$
}

FUNCTION {new.sentence.checka}
{ empty$
    'skip$
    'new.sentence
  if$
}

FUNCTION {new.sentence.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.sentence
  if$
}

FUNCTION {field.or.null}
{ duplicate$ empty$
    { pop$ "" }
    'skip$
  if$
}

FUNCTION {namefont}
{ duplicate$ empty$
    { pop$ "" }
    { "\btxnamefont {" swap$ * "}" * }
  if$
}

FUNCTION {lastnamefont}
{ duplicate$ empty$
    { pop$ "" }
    { "\btxlastnamefont {" swap$ * "}" * }
  if$
}
FUNCTION {titlefont}
{ duplicate$ empty$
    { pop$ "" }
    { "\btxtitlefont {" swap$ * "}" * }
  if$
}
FUNCTION {jtitlefont}
{ duplicate$ empty$
    { pop$ "" }
    { "\btxjtitlefont {" swap$ * "}" * }
  if$
}
FUNCTION {journalfont}
{ duplicate$ empty$
    { pop$ "" }
    { "\btxjournalfont {" swap$ * "}" * }
  if$
}
FUNCTION {publisherfont}
{ duplicate$ empty$
    { pop$ "" }
    { "\btxpublisherfont {" swap$ * "}" * }
  if$
}
FUNCTION {volumefont}
{ duplicate$ empty$
    { pop$ "" }
    { "\btxvolumefont {" swap$ * "}" * }
  if$
}

FUNCTION {etalfont}
{ duplicate$ empty$
    { pop$ "" }
    { "\btxetalfont {" swap$ * "}" * }
  if$
}

INTEGERS { nameptr namesleft numnames }

FUNCTION {format.names}
{ 's :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { nameptr #1 >
      {
        s nameptr "{ll}" format.name$ lastnamefont
        s nameptr "{,~jj}{,~f{.\btxfnamespaceshort }.}{~vv}" format.name$ *
        't :=
          namesleft #1 >
            { ", " * t namefont * }
            {
              s nameptr "{ff~}{vv~}{ll}{, jj}" format.name$ "others" =
                { " " "\btxetalshort {.}" etalfont * * }
                { " \btxandshort {.}\ " * t namefont * }
              if$
            }
          if$
        }
        {
          s nameptr "{ll}" format.name$ lastnamefont
          s nameptr "{,~jj}{,~f{.\btxfnamespaceshort }.}{~vv}"
          format.name$ * namefont
        }
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}

FUNCTION {format.key}
{ empty$
    { key field.or.null }
    { "" }
  if$
}

FUNCTION {format.authors}
{ author empty$
    { "" }
    { author format.names }
  if$
}

FUNCTION {format.editors}
{ editor empty$
    { "" }
    { editor format.names
      editor num.names$ #1 >
        { "\ (\btxeditorsshort {.})" * }
        { "\ (\btxeditorshort {.})" * }
      if$
    }
  if$
}
FUNCTION {format.title}
{ title empty$
    { "" }
    { title "t" language.change.case titlefont }
  if$
}
FUNCTION {format.jtitle}
{ title empty$
    { "" }
    { title "t" language.change.case jtitlefont }
  if$
}
FUNCTION {n.dashify}
{ 't :=
  ""
    { t empty$ not }
    { t #1 #1 substring$ "-" =
        { t #1 #2 substring$ "--" = not
            { "--" *
              t #2 global.max$ substring$ 't :=
            }
            {   { t #1 #1 substring$ "-" = }
                { "-" *
                  t #2 global.max$ substring$ 't :=
                }
              while$
            }
          if$
        }
        { t #1 #1 substring$ *
          t #2 global.max$ substring$ 't :=
        }
      if$
    }
  while$
}

FUNCTION {format.date}
{ year empty$
    { month empty$
        { "" }
        { "there's a month but no year in " cite$ * warning$
          month
        }
      if$
    }
    { month empty$
        'year
        { "\btxprintmonthyear{.}{"
          month * "}{" * year * "}{short}" *
        }
      if$
    }
  if$
}

FUNCTION {format.year}
{ year empty$
    { "empty year in " cite$ * warning$
      extra.label 
    }
    { "(" year * extra.label * ")" * }
  if$
}

FUNCTION {format.btitle}
{ title titlefont
}

FUNCTION {format.booktitle}
{ booktitle titlefont
}

FUNCTION {tie.or.space.connect}
{ duplicate$ text.length$ #3 <
    { "~" }
    { "\ " }
  if$
  swap$ * *
}

FUNCTION {volume.tie.or.space.connect}
{ duplicate$ text.length$ #3 <
    { "~" }
    { "\ " }
  if$
  swap$ volumefont * *
}

FUNCTION {tie.or.space.connect.reverse}
{ swap$
  duplicate$ text.length$ #3 <
    { swap$ "~" }
    { swap$ "\ " }
  if$
  swap$ * *
}

FUNCTION {either.or.check}
{ empty$
    'pop$
    { "can't use both " swap$ * " fields in " * cite$ * warning$ }
  if$
}

FUNCTION {format.bvolume}
{ volume empty$
    { "" }
    { series empty$
        { output.state after.block =
            { "\Btxvolumeshort {.}" }
            { "\btxvolumeshort {.}" }
          if$
        }
        { series titlefont }
      if$
      volume volume.tie.or.space.connect
      "volume and number" number either.or.check
    }
  if$
}

FUNCTION {format.number.series}
{ volume empty$
    { number empty$
        { series field.or.null }
        { series empty$
            { "there's a number but no series in " cite$ * warning$
              ""
            }
            { series }
          if$
          number tie.or.space.connect
        }
      if$
    }
    { "" }
  if$
}

FUNCTION {format.edition}
{ edition empty$
    { "" }
    {
      output.state mid.sentence =
        { edition "l" change.case$ }
        { edition "t" change.case$ }
      if$
      "\btxeditionnumshort {" swap$ *
      "}{.}" *
    }
  if$
}

FUNCTION {format.isbn}
{ isbn empty$
    { "" }
    { "\mbox{\btxISBN~\btxISBNfont {" isbn * "}}" * }
  if$
}

FUNCTION {format.issn}
{ issn empty$
    { "" }
    { "\mbox{\btxISSN~\btxISSNfont {" issn * "}}" * }
  if$
}

% selectlanguage adds a space after the text due to a bug in finnish.ldf, so use foreignlanguage to not get a space before the comma
FUNCTION {format.howpublished}
{ howpublished empty$
    { "" }
    { "\expandafter\foreignlanguage\expandafter {\biblanguagename}{" howpublished * "}" * }
  if$
}

FUNCTION {format.note}
{ note empty$
    { "" }
    { "\expandafter\foreignlanguage\expandafter {\btxfallbacklanguage}{" note * "}" * }
  if$
}

FUNCTION {format.urldate}
{ urldate empty$
    { "" }
    { " (\btxurldatecomment {\btxurldatefont{" urldate * "}})" * }
  if$
}

FUNCTION {format.url}
{ url empty$
    { "" }
    { "{\expandafter\selectlanguage\expandafter {\btxfallbacklanguage}\btxurlcomment{}" format.urldate * ": {\latintext \btxurlfont{" * url * "}}}" * } 
  if$
}

FUNCTION {format.full.names}
{'s :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { s nameptr
      "{vv~}" format.name$
      s nameptr "{ll}" format.name$ lastnamefont *
      s nameptr "{,~jj}" format.name$ *
      't :=
      nameptr #1 >
        {
          namesleft #1 >
            { ", " * t namefont * }
            {
              t "others" =
                { " " "\btxetalshort {.}" etalfont * * }
                { " \btxandshort {.} " * t namefont * }
              if$
            }
          if$
        }
        't
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}

FUNCTION {author.editor.full}
{ author empty$
    { editor empty$
        { "" }
        { editor format.full.names }
      if$
    }
    { author format.full.names }
  if$
}

FUNCTION {author.full}
{ author empty$
    { "" }
    { author format.full.names }
  if$
}

FUNCTION {editor.full}
{ editor empty$
    { "" }
    { editor format.full.names }
  if$
}

FUNCTION {make.full.names}
{ type$ "book" =
  type$ "inbook" =
  or
    'author.editor.full
    { type$ "proceedings" =
        'editor.full
        'author.full
      if$
    }
  if$
}

FUNCTION {write.annote}
{ annote empty$
  'skip$
  {
    annotelanguage empty$
    { "\btxkeywordlanguage {" }
    { "{\selectlanguage {" annotelanguage * "}" * }
    if$
    "\btxannotation {" * annote * "}}" *
    write$ newline$
  }
  if$
}
INTEGERS { multiresult }

FUNCTION {multi.page.check}
{ 't :=
  #0 'multiresult :=
    { multiresult not
      t empty$ not
      and
    }
    { t #1 #1 substring$
      duplicate$ "-" =
      swap$ duplicate$ "," =
      swap$ "+" =
      or or
        { #1 'multiresult := }
        { t #2 global.max$ substring$ 't := }
      if$
    }
  while$
  multiresult
}

FUNCTION {format.pages}
{ pages empty$
    { "" }
    { pages multi.page.check
        { "\btxpagesshort {.}" pages n.dashify tie.or.space.connect }
        { "\btxpageshort {.}" pages tie.or.space.connect }
      if$
    }
  if$
}

FUNCTION {format.numpages.numappendixpages}
{ numpages empty$
  pagetotal empty$
  and
    { numappendixpages empty$
        { "" }
        {"there's a numappendixpages but no numpages in " cite$ * warning$ }
      if$
    }
    { numpages empty$
        { pagetotal "\btxpageshort {.}" tie.or.space.connect.reverse }
        { numpages "\btxpageshort {.}" tie.or.space.connect.reverse
          "numpages and pagetotal" pagetotal either.or.check
        }
      if$
      numappendixpages empty$
        'skip$
        { " + \btxappendicesshort{.} " * numappendixpages "\btxpageshort{.}" tie.or.space.connect.reverse * }
      if$
    }
  if$
}

% The babelbib vocabulary contains no distinct word for "volume" in the "set of issues" sense, so we'll have to define our own. Patch submitted to babelbib maintainer with the new vocabulary Sep 2017
FUNCTION {format.jvol.num}
{ volume empty$
    { "" }
    { output.state after.block = 
        { "\Btxjvolumeshort {.}" volume tie.or.space.connect }
        { "\btxjvolumeshort {.}" volume tie.or.space.connect }
      if$
    }
  if$
  number empty$
    'skip$
    { volume empty$
        { year empty$
            { "there's a number but no volume in " cite$ * warning$ }
            { year * }
          if$
        }
        'skip$
      if$
      "(" number * ")" * *
    }
  if$
}

FUNCTION {format.chapter}
{ chapter empty$
    { "" }
    { type empty$
        { output.state mid.sentence =
            { "\btxchapterlong {.}" }
            { "\Btxchapterlong {.}" }
          if$
        }
        { type }
      if$
      chapter tie.or.space.connect
    }
  if$
}

FUNCTION {format.chapter.pages}
{ chapter empty$
    'format.pages
    { type empty$
        { "\btxchapterlong {.}" }
        { type }
      if$
      chapter tie.or.space.connect
      pages empty$
        'skip$
        { ", " * format.pages * }
      if$
    }
  if$
}

FUNCTION {format.in}
{ output.state mid.sentence =
  output.state before.incollection.in =
  or
    { "\btxinshort {.}:\ " }
    { "\Btxinshort {.}:\ " }
  if$
}

FUNCTION {format.in.ed.booktitle}
{ booktitle empty$
    { "" }
    { format.in
      editor empty$
        { format.booktitle * }
        { format.editors * ", " * format.booktitle * }
      if$
    }
  if$
}

FUNCTION {empty.misc.check}
{ author empty$ title empty$ howpublished empty$
  month empty$ year empty$ note empty$
  and and and and and
  key empty$ not and
    { "all relevant fields are empty in " cite$ * warning$ }
    'skip$
  if$
}

FUNCTION {format.thesis.type}
{ type empty$
    'skip$
    { pop$
      "\expandafter\foreignlanguage\expandafter {\biblanguagename}{" type * "}" * 
    }
  if$
}

FUNCTION {format.tr.number}
{
  number empty$
  {
    type empty$
      { "\btxtechrepshort {.}" }
      { type }
    if$
  }
  {
    type empty$
      { "\Btxtechrepshort {.}" }
      { type }
    if$
    number tie.or.space.connect
  }
  if$
}

FUNCTION {format.conferenceplace}
{ venue empty$
    { address empty$
        { "" }
        { address }
      if$
    }
    { venue
      "venue and address" address either.or.check
    }
  if$
}

FUNCTION {format.title.place.date}
{
  title empty$
    { "" }
    {
      venue empty$
      address empty$
      and
        { "there's no conference place in " cite$ * warning$
          title
        }
        { title ", " * format.conferenceplace * }
      if$
      year empty$
        { "there's no year in " cite$ * warning$ }
        { ", " * format.date * }
      if$
    }
  if$
}

FUNCTION {format.title.organization.place.date}
{
  title empty$
    { "" }
    {
      organization empty$
        { title }
        { title ", " * organization * }
      if$
      venue empty$
      address empty$
      and
        { "there's no conference place in " cite$ * warning$ }
        { ", " * format.conferenceplace * }
      if$
      year empty$
        { "there's no year in " cite$ * warning$ }
        { ", " * format.date * }
      if$
    }
  if$
}

FUNCTION {format.booktitle.organization.place.date}
{
  booktitle empty$
    { "" }
    {
      organization empty$
        { booktitle }
        { booktitle ", " * organization * }
      if$
      venue empty$
      address empty$
      and
        { "there's no conference place in " cite$ * warning$ }
        { ", " * format.conferenceplace * }
      if$
      year empty$
        { "there's no year in " cite$ * warning$ }
        { ", " * format.date * }
      if$
    }
  if$
}

FUNCTION {format.in.proceedings}
{ booktitle empty$
    { "" }
    { editor empty$
        { format.in }
        { format.in format.editors * ", " * }
      if$
      format.booktitle.organization.place.date titlefont *
    }
  if$
}

FUNCTION {format.article.crossref}
{ journal empty$
    { "need journal for " cite$ * " to crossref " * crossref *
      warning$
      "" *
    }
    { format.in journal journalfont * }
  if$
  key empty$
    { " \citeyearpar{" * crossref * "}" * }
    { " \citep{" * crossref * "}" * }
  if$
}

FUNCTION {format.book.crossref}
{ volume empty$
    { "empty volume in " cite$ * "'s crossref of " * crossref * warning$
      "\Btxinshort {.}\ "
    }
    { output.state mid.sentence =
        { "\btxvolumeshort {.}" volume volume.tie.or.space.connect }
        { "\Btxvolumeshort {.}" volume volume.tie.or.space.connect }
      if$ 
      " \btxofseriesshort {.}\ " *
    }
  if$
  editor empty$
  editor field.or.null author field.or.null =
  or
    { series empty$
        { "need editor or series for " cite$ * " to crossref " *
          crossref * warning$
          "" *
        }
        { series titlefont * }
      if$
      " \citeyearpar{" * crossref * "}" *
    }
    { " \citet{" * crossref * "}" * }
  if$
}

FUNCTION {format.incoll.inproc.crossref}
{ editor empty$
  editor field.or.null author field.or.null =
  or
    { booktitle empty$
        { key empty$
            { "need editor, booktitle or key for " cite$ * " to crossref " *
              crossref * warning$
              ""
            }
            { format.in key titlefont * 
              " \citeyearpar{" * crossref * "}" *
            }
          if$
        }
        { type$ "inproceedings" =
% In case we would like to enable lowercasing for book titles, we still want to skip it for conferences
            { format.in booktitle titlefont * }
            { format.in format.booktitle * }
          if$
          key empty$
          organization empty$
          and
            { " \citeyearpar{" * crossref * "}" * }
            { " \citep{" * crossref * "}" * }
          if$
        }
      if$
    }
    { format.in " \citet{" * crossref * "}" * }
  if$
}

FUNCTION {output.bibitem}
{ newline$
  language empty$
    {
      language.state "nolanguage" =
        'skip$
        {
          "empty language in " cite$ * warning$
          "\expandafter\btxselectlanguage\expandafter {"
          "\btxfallbacklanguage}" *
          write$ newline$
        }
      if$
      "nolanguage" 'language.state :=
    }
    {
      language.state language =
        'skip$
        {
          "\btxselectlanguage {" language * "}" *
          write$ newline$
        }
      if$
      language 'language.state :=
    }
  if$
  "\bibitem[" write$
  label write$
  ")" make.full.names duplicate$ short.list =
     { pop$ }
     { * }
   if$
  "]{" * write$
  cite$ write$
  "}" write$
  newline$
  ""
  before.all 'output.state :=
}

FUNCTION {article}
{ output.bibitem
  author empty$
    { title empty$
        { key empty$
            { journal titlefont "author, title, key and journal" output.check }
            { key output.nonnull }
          if$
        }
        { format.jtitle output.nonnull }
      if$
    }
    { format.authors output.nonnull }
  if$
  after.authors
  format.year "year" output.check
  new.sentence
  author empty$
    'skip$
    { format.jtitle "title" output.check }
  if$
  new.block
  crossref missing$
    { key empty$
      title missing$
      and
      author empty$
      and
        'skip$
        { journal journalfont "title, key and journal" output.check }
      if$
      format.jvol.num output
      % Notice that only for article, we print note in the entry language, not in the keyword language
    }
    { format.article.crossref output.nonnull }
  if$
  note output
  format.issn "\ifbtxprintISSN" output.isbn
  format.pages output
  new.block
  add.period$
  urldate empty$
    {}
    {format.url output}
  if$
  fin.entry
  write.annote
}

FUNCTION {book}
{ output.bibitem
  author empty$
    { editor empty$
         { format.btitle "author, editor and title" output.check }
         { format.editors output.nonnull }
      if$
    }
    { format.authors output.nonnull
      crossref missing$
        { "author and editor" editor either.or.check }
        'skip$
      if$
    }
  if$
  after.authors
  format.year "year" output.check
  new.sentence
  author empty$
  editor empty$
  and
    'skip$
    { format.btitle "title" output.check }
  if$
  crossref missing$
    { format.edition output
      format.bvolume output
      new.sentence
      publisher "publisher" output.check publisherfont
      format.number.series output
      address output
    }
    { new.sentence
      format.book.crossref output.nonnull
      format.edition output
    }
  if$
  format.isbn "\ifbtxprintISBN" output.isbn
  format.numpages.numappendixpages "numpages" output.check
  new.block
  format.note output
  new.block
  add.period$
  format.url output
  fin.entry
  write.annote
}

FUNCTION {booklet}
{ output.bibitem
  author empty$
    { format.title "title" output.check
      after.authors
      format.year "year" output.check
    }
    { format.authors output.nonnull
      after.authors
      format.year "year" output.check
      new.sentence
      format.title "title" output.check
    }
  if$
  new.sentence
  format.howpublished output
  address output
  format.numpages.numappendixpages output
  new.block
  format.note output
  new.block
  add.period$
  format.url output
  fin.entry
  write.annote
}

FUNCTION {inbook}
{ output.bibitem
  author empty$
    { editor empty$
        { format.btitle "author, editor and title" }
        { format.editors output.nonnull }
      if$
    }
    { format.authors output.nonnull
      crossref missing$
        { "author and editor" editor either.or.check }
        'skip$
      if$
    }
  if$
  after.authors
  format.year "year" output.check
  new.sentence
  author empty$
  editor empty$
  and
    'skip$
    { format.btitle "title" output.check }
  if$
  crossref missing$
    { format.edition output
      series empty$
        { format.bvolume output
          format.chapter output
          new.sentence
        }
        { format.chapter output
          new.sentence
          format.bvolume output
        }
      if$
      publisher "publisher" output.check publisherfont
      format.number.series output
      address output
    }
    { format.chapter.pages "chapter and pages" output.check
      new.sentence
      format.book.crossref output.nonnull
      format.edition output
    }
  if$
  format.isbn "\ifbtxprintISBN" output.isbn
  format.pages output
  new.block
  format.note output
  new.block
  add.period$
  format.url output
  fin.entry
  write.annote
}

FUNCTION {incollection}
{ output.bibitem
  author empty$
    { format.jtitle "title" output.check
      after.authors
      format.year "year" output.check
    }
    { format.authors "author" output.check
      after.authors
      format.year "year" output.check
      new.sentence
      format.jtitle "title" output.check
    }
  if$
  new.block
  chapter empty$
    'skip$
    { format.chapter output 
      after.incollection.chapter
    }
  if$
  crossref missing$
    { format.in.ed.booktitle "booktitle" output.check
      format.edition output
      series empty$
        { format.bvolume output
          new.sentence
        }
        { new.sentence
          format.bvolume output
        }
      if$
      publisher "publisher" output.check publisherfont
      format.number.series output
      address output
    }
    { format.incoll.inproc.crossref output.nonnull }
  if$
  format.isbn "\ifbtxprintISBN" output.isbn
  format.pages output
  new.block
  format.note output
  new.block
  add.period$
  format.url output
  fin.entry
  write.annote
}

FUNCTION {inproceedings}
{ output.bibitem
  format.authors "author" output.check
  after.authors
  format.year "year" output.check
  new.sentence
  format.jtitle "title" output.check
  new.block
  crossref missing$
    { format.in.proceedings "booktitle" output.check
      series empty$
        { format.bvolume output
          new.sentence
        }
        { new.sentence
          format.bvolume output
        }
      if$
      publisher publisherfont output
      format.number.series output
      location output
    }
    { format.incoll.inproc.crossref output.nonnull }
  if$
  format.isbn "\ifbtxprintISBN" output.isbn
  format.pages output
  new.block
  format.note output
  new.block
  add.period$
  urldate empty$
    {}
    {format.url output}
  if$
  fin.entry
  write.annote
}

FUNCTION {conference} { inproceedings }

FUNCTION {manual}
{ output.bibitem
  author empty$
    { format.title "title" output.check
      after.authors
      format.year "year" output.check
    }
    { format.authors output.nonnull
      after.authors
      format.year "year" output.check
      new.sentence
      format.title "title" output.check
    }
  if$
  new.sentence
  format.edition output
  author empty$
    {organization "author and organization" output.check}
    {organization output}
  if$
  address output
  format.isbn "\ifbtxprintISBN" output.isbn
  format.numpages.numappendixpages output
  new.block
  format.note output
  new.block
  add.period$
  format.url output
  fin.entry
  write.annote
}

FUNCTION {mastersthesis}
{ output.bibitem
  format.authors "author" output.check
  after.authors
  format.year "year" output.check
  new.sentence
  series empty$
    { format.title "title" output.check }
    { format.btitle "title" output.check }
  if$
  "\btxmastthesis {}" format.thesis.type output.nonnull
  new.sentence
  school "school" output.check
  format.number.series output
  address output
  format.numpages.numappendixpages "numpages" output.check
  new.block
  format.note output
  new.block
  add.period$
  format.url output
  fin.entry
  write.annote
}

FUNCTION {misc}
{ output.bibitem
  author empty$
    { format.title "author and title" output.check
      after.authors
      format.year output
    }
    { format.authors output.nonnull
      after.authors
      format.year output
      new.sentence
      format.title output
    }
  if$
  new.sentence
  format.howpublished output
  format.isbn "\ifbtxprintISBN" output.isbn
  format.issn "\ifbtxprintISSN" output.isbn
  format.numpages.numappendixpages output
  new.block
  format.note output
  new.block
  add.period$
  format.url output
  fin.entry
  write.annote
  empty.misc.check
}

FUNCTION {phdthesis}
{ output.bibitem
  format.authors "author" output.check
  after.authors
  format.year "year" output.check
  new.sentence
  format.btitle "title" output.check
  "\btxphdthesis {}" format.thesis.type output.nonnull
  new.sentence
  school "school" output.check
  format.number.series output
  address output
  format.isbn "\ifbtxprintISBN" output.isbn
  format.numpages.numappendixpages "numpages" output.check
  new.block
  format.note output
  new.block
  add.period$
  format.url output
  fin.entry
  write.annote
}

FUNCTION {proceedings}
{ output.bibitem
  editor empty$
    { key empty$
        { organization empty$
            { format.title.place.date "title" output.check titlefont }
            { organization output }
          if$
        }
       { key output.nonnull }
      if$
    }
    { format.editors output.nonnull }
  if$
  after.authors
  format.year "year" output.check
  new.sentence
  editor empty$
    { key empty$
        { organization empty$
            'skip$
            { format.title.place.date "title" output.check titlefont }
          if$
        }
        { format.title.organization.place.date "title" output.check titlefont }
      if$
    }
    { format.title.organization.place.date "title" output.check titlefont }
  if$
  series empty$
    { format.bvolume output 
      new.sentence
    }
    { new.sentence
      format.bvolume output
    }
  if$
  publisher publisherfont output
  format.number.series output
  location output
  format.isbn "\ifbtxprintISBN" output.isbn
  format.numpages.numappendixpages output
  new.block
  format.note output
  new.block
  add.period$
  urldate empty$
    'skip$
    { format.url output }
  if$
  fin.entry
  write.annote
}

FUNCTION {techreport}
{ output.bibitem
  key empty$ not
  number missing$
  or
  type missing$
  or
  author empty$
  and
    { format.btitle "title" output.check
      after.authors
      format.year "year" output.check
      new.sentence
      institution "institution" output.check
      format.tr.number output.nonnull
    }
    { author empty$
        { format.tr.number output.nonnull }
        { format.authors output.nonnull }
      if$
      after.authors
      format.year "year" output.check
      new.sentence
      format.btitle "title" output.check
      new.sentence
      institution "institution" output.check
      author missing$
        'skip$
        { format.tr.number output.nonnull }
      if$
    }
  if$
  address output
  format.isbn "\ifbtxprintISBN" output.isbn
  format.numpages.numappendixpages output
  new.block
  format.note output
  new.block
  add.period$
  format.url output
  fin.entry
  write.annote
}

FUNCTION {unpublished}
{ output.bibitem
  author empty$
    { format.title "title" output.check
      after.authors
      format.year "year" output.check
    }
    { format.authors "author" output.check
      after.authors
      format.year "year" output.check
      new.sentence
      format.title "title" output.check
    }
  if$
  new.sentence
  format.note "note" output.check
  format.numpages.numappendixpages output
  new.block
  add.period$
  format.url output
  fin.entry
  write.annote
}

FUNCTION {default.type} { misc }

MACRO {jan} {"1"}
MACRO {feb} {"2"}
MACRO {mar} {"3"}
MACRO {apr} {"4"}
MACRO {may} {"5"}
MACRO {jun} {"6"}
MACRO {jul} {"7"}
MACRO {aug} {"8"}
MACRO {sep} {"9"}
MACRO {oct} {"10"}
MACRO {nov} {"11"}
MACRO {dec} {"12"}
MACRO {acmcs} {"ACM Comput.\ Surv.{}"}
MACRO {acta} {"Acta Inf.{}"}
MACRO {cacm} {"Commun. ACM"}
MACRO {ibmjrd} {"IBM J.~Res.\ Dev.{}"}
MACRO {ibmsj} {"IBM Syst.~J.{}"}
MACRO {ieeese} {"IEEE Trans.\ Softw.\ Eng.{}"}
MACRO {ieeetc} {"IEEE Trans.\ Comput.{}"}
MACRO {ieeetcad}
 {"IEEE Trans.\ Comput.-Aided Design Integrated Circuits"}
MACRO {ipl} {"Inf.\ Process.\ Lett.{}"}
MACRO {jacm} {"J.~ACM"}
MACRO {jcss} {"J.~Comput.\ Syst.\ Sci.{}"}
MACRO {scp} {"Sci.\ Comput.\ Programming"}
MACRO {sicomp} {"SIAM J.~Comput.{}"}
MACRO {tocs} {"ACM Trans.\ Comput.\ Syst.{}"}
MACRO {tods} {"ACM Trans.\ Database Syst.{}"}
MACRO {tog} {"ACM Trans.\ Gr.{}"}
MACRO {toms} {"ACM Trans.\ Math.\ Softw.{}"}
MACRO {toois} {"ACM Trans.\ Office Inf.\ Syst.{}"}
MACRO {toplas} {"ACM Trans.\ Prog.\ Lang.\ Syst.{}"}
MACRO {tcs} {"Theoretical Comput.\ Sci.{}"}

READ

FUNCTION {sortify}
{ purify$
  "l" change.case$
}

INTEGERS { len }

FUNCTION {chop.word}
{ 's :=
  'len :=
  s #1 len substring$ =
    { s len #1 + global.max$ substring$ }
    's
  if$
}

FUNCTION {format.lab.names}
{ 's :=
  s #1
  "{vv~}" format.name$
  s #1 "{ll}" format.name$ lastnamefont *
  s num.names$ duplicate$
  #2 >
    { pop$ " " "\btxetalshort {.}" etalfont * * }
    { #2 <
        'skip$
        { s #2 "{ff }{vv }{ll}{ jj}" format.name$ "others" =
            { " " "\btxetalshort {.}" etalfont * * }
            { " \btxandshort {.}\ " * s #2 "{vv~}{ll}"
              format.name$ namefont * }
          if$
        }
      if$
    }
  if$
}

FUNCTION {author.key.label}
{ author empty$
    { key empty$
        { title empty$
            { cite$ #1 #3 substring$ }
            'title
          if$
        }
        'key
      if$
    }
    { author format.lab.names }
  if$
}

FUNCTION {author.editor.key.label}
{ author empty$
    { editor empty$
        { key empty$
            { title empty$
                { cite$ #1 #3 substring$ }
                'title
              if$
            }
            'key
          if$
        }
        { editor format.lab.names }
      if$
    }
    { author format.lab.names }
  if$
}

FUNCTION {author.key.trnumber.label}
{ author empty$
    { key empty$
        { number empty$
          type empty$
          or
            { title empty$
                { cite$ #1 #3 substring$ }
                'title
            }
            { type " " * number * }
          if$
        }
        'key
      if$
    }
    { author format.lab.names }
  if$
}

FUNCTION {editor.key.organization.label}
{ editor empty$
    { key empty$
        { organization empty$
            { cite$ #1 #3 substring$ }
            { "The " #4 organization chop.word #3 text.prefix$ }
          if$
        }
        'key
      if$
    }
    { editor format.lab.names }
  if$
}

FUNCTION {calc.short.authors}
{ type$ "book" =
  type$ "inbook" =
  or
    'author.editor.key.label
    { type$ "proceedings" =
        'editor.key.organization.label
        { type$ "techreport" =
            'author.key.trnumber.label
            'author.key.label
          if$
        }
      if$
    }
  if$
  'short.list :=
}

FUNCTION {calc.label}
{ calc.short.authors
  short.list
  "("
  *
  year duplicate$ empty$
     { pop$ "" }
     'skip$
  if$
  *
  'label :=
}

FUNCTION {sort.format.names}
{ 's :=
  #1 'nameptr :=
  ""
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    {
      s nameptr "{ll{ }}{  f{ }}{vv{ } }{  jj{ }}" format.name$ 't :=
      nameptr #1 >
        {
          "   "  *
          namesleft #1 = t "others" = and
            { "zzzzz" * }
            { numnames #2 > nameptr #2 = and
                { "zz" * year field.or.null * "   " * }
                'skip$
              if$
              t sortify *
            }
          if$
        }
        { t sortify * }
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}

FUNCTION {sort.format.title}
{ 't :=
  "A " #2
    "An " #3
      "The " #4 t chop.word
    chop.word
  chop.word
  sortify
  #1 global.max$ substring$
}

% Even if someone uses a key that is e.g. the first word of the title, we still want to sort by the full title
FUNCTION {author.title.sort}
{ author empty$
    { title empty$
        { "to sort, need author or title in " cite$ * warning$
           ""
        }
        { title sort.format.title }
      if$
    }
    { author sort.format.names }
  if$
}

FUNCTION {author.editor.title.sort}
{ author empty$
    { editor empty$
        { title empty$
            { "to sort, need author, editor, or title in " cite$ * warning$
              ""
            }
            { title sort.format.title }
          if$
        }
        { editor sort.format.names }
      if$
    }
    { author sort.format.names }
  if$
}

FUNCTION {editor.key.organization.title.sort}
{ editor empty$
    { key empty$ 
        { organization empty$
            { title empty$
                { "to sort, need editor, key, organization, or title in " cite$ * warning$
                  ""
                }
                { title sort.format.title }
              if$
            }
            { "The " #4 organization chop.word sortify }
          if$
        }
        { key sortify }
      if$
    }
    { editor sort.format.names }
  if$
}

FUNCTION {author.trnumber.title.sort}
{ author empty$
    { key empty$
        { number empty$
          type empty$
          or
            { "to sort, need author, key or type+number in " cite$ * warning$
              ""
            }
            { type " " * number * sortify }
          if$
        }
        { title sort.format.title }
      if$
    }
    { author sort.format.names }
  if$
}

FUNCTION {key.journal.sort}
{ key empty$
    { journal empty$
        { "to sort, need author, title, key or journal in " cite$ * warning$
          ""
        }
        { journal sort.format.title }
      if$
    }
    { key sortify }
  if$
}

FUNCTION {presort}
{ calc.label
  label sortify
  "    "
  *
  type$ "book" =
  type$ "inbook" =
  or
    'author.editor.title.sort
    { type$ "proceedings" =
        'editor.key.organization.title.sort
        { type$ "techreport" =
            'author.trnumber.title.sort
            { author empty$
              title empty$
              and
              type$ "article" =
              and
                'key.journal.sort
                'author.title.sort
              if$
            }
          if$
        }
      if$
    }
  if$
  "    "
  *
  year field.or.null sortify
  *
  "    "
  *
  title field.or.null
  sort.format.title
  *
  #1 entry.max$ substring$
  'sort.label :=
  sort.label *
  #1 entry.max$ substring$

  'sort.key$ :=
}

ITERATE {presort}

SORT

STRINGS { longest.label last.label next.extra }

INTEGERS { longest.label.width last.extra.num number.label }

FUNCTION {initialize.longest.label}
{ "" 'longest.label :=
  #0 int.to.chr$ 'last.label :=
  "" 'next.extra :=
  #0 'longest.label.width :=
  #0 'last.extra.num :=
  #0 'number.label :=
}

FUNCTION {forward.pass}
{ last.label label =
    { last.extra.num #1 + 'last.extra.num :=
      last.extra.num int.to.chr$ 'extra.label :=
    }
    { "a" chr.to.int$ 'last.extra.num :=
      "" 'extra.label :=
      label 'last.label :=
    }
  if$
  number.label #1 + 'number.label :=
}

FUNCTION {reverse.pass}
{ next.extra "b" =
    { "a" 'extra.label := }
    'skip$
  if$
  extra.label 'next.extra :=
  extra.label
  duplicate$ empty$
    'skip$
    { "{\natexlab{" swap$ * "}}" * }
  if$
  'extra.label :=
  label extra.label * 'label :=
}

EXECUTE {initialize.longest.label}

ITERATE {forward.pass}

REVERSE {reverse.pass}

FUNCTION {bib.sort.order}
{ sort.label  'sort.key$ :=
}

ITERATE {bib.sort.order}

SORT

FUNCTION {begin.bib}
{
  preamble$ empty$
    'skip$
    { preamble$ write$ newline$ }
  if$
  "\begin{thebibliography}{" number.label int.to.str$ * "}" * write$ newline$
  "\providecommand{\natexlab}[1]{#1}" write$ newline$
  "\providecommand{\url}[1]{\texttt{#1}}" write$ newline$

  "  \providebibliographyfont{name}{}%" write$ newline$
  "  \providebibliographyfont{lastname}{}%" write$ newline$
  "  \providebibliographyfont{title}{}%" write$ newline$
  "  \providebibliographyfont{jtitle}{}%" write$ newline$
  "  \providebibliographyfont{etal}{\emph}%" write$ newline$
  "  \providebibliographyfont{journal}{}%" write$ newline$
  "  \providebibliographyfont{volume}{}%" write$ newline$
  "  \providebibliographyfont{ISBN}{\MakeUppercase}%" write$ newline$
  "  \providebibliographyfont{ISSN}{\MakeUppercase}%" write$ newline$
  "  \providebibliographyfont{url}{\url}%" write$ newline$
  "  \providebibliographyfont{urldate}{\tformatdate}%" write$ newline$
  "  \providebibliographyfont{numeral}{}%" write$ newline$

  "  \renewcommand\btxauthorcolon{,}%" write$ newline$

  "  \def\tformatdate#1{\@tformatdate #1\stopmark}%" write$ newline$
  "  \def\@tformatdate #1-#2-#3\stopmark{\number#3\relax.\number#2\relax.#1}%" write$ newline$

  "  \let\oldprintmonthyear\btxprintmonthyear%" write$ newline$
  "  \def\btxprintmonthyear#1#2#3#4{\ifnumber{#2}{\oldprintmonthyear{#1}{#2}{#3}{#4}}{#2,\ #3}}%" write$ newline$

  "  \expandafter\btxselectlanguage\expandafter {\btxfallbacklanguage}%" write$ newline$

% Something strange happens with arguments inside the addto depending on whether the babelbib language is loaded, so we will wrap the language definitions in conditional blocks

  "  \ifx\datefinnish\undefined\else\addto\bibsfinnish{%" write$ newline$
  "    \renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  % The Finnish translation has some typos and poor style. Patch submitted to maintainer Sep 2017
  "    \renewcommand{\Btxvolumeshort}[1]{\protect\foreignlanguage{\biblanguagename}{Nide}}%" write$ newline$
  "    \let\btxpagesshort\btxpageshort%" write$ newline$
  "    \let\Btxpagesshort\Btxpageshort%" write$ newline$
  "    \renewcommand{\btxmastthesis}[1]{\protect\foreignlanguage{\biblanguagename}{pro gradu -ty\" write$ quote$ write$ "o}}%" write$ newline$
  "    \renewcommand{\btxurldatecomment}[1]{\protect\foreignlanguage{\biblanguagename}{viitattu #1}}%" write$ newline$
  "    \def\btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{vsk#1{}}}%" write$ newline$
  "    \def\Btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{Vsk#1{}}}%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{liitt#1{}}}%" write$ newline$
  "    \def\btxurlcomment#1{\protect\foreignlanguage{\biblanguagename}{Saatavissa}}%" write$ newline$
  "  }\fi%" write$ newline$

  "  \ifx\dateenglish\undefined\else\addto\bibsenglish{%" write$ newline$
  "    \renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  "    \let\btxvolumeshort\Btxvolumeshort%" write$ newline$
  "    \let\btxchapterlong\Btxchapterlong%" write$ newline$
  "    \renewcommand{\btxmastthesis}[1]{\protect\foreignlanguage{\biblanguagename}{master's thesis}}%" write$ newline$
  "    \renewcommand{\btxphdthesis}[1]{\protect\foreignlanguage{\biblanguagename}{dissertation}}%" write$ newline$
  "    \renewcommand{\btxurldatecomment}[1]{\protect\foreignlanguage{\biblanguagename}{accessed on #1}}%" write$ newline$
  "    \let\btxjvolumeshort\Btxvolumeshort%" write$ newline$
  "    \let\Btxjvolumeshort\Btxvolumeshort%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{app#1{}}}%" write$ newline$
  "    \def\btxurlcomment#1{\protect\foreignlanguage{\biblanguagename}{Available}}%" write$ newline$
  "  }\fi%" write$ newline$

  "  \ifx\dateafrikaans\undefined\else\addto\bibsafrikaans{\renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  "    \renewcommand{\btxmastthesis}[1]{\protect\foreignlanguage{\biblanguagename}{magistertesis}}%" write$ newline$
  "    \def\btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{jg#1{}}}\def\Btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{Jg#1{}}}%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{byl#1{}}}}\fi%" write$ newline$

  "  \ifx\datebahasa\undefined\else\addto\bibsbahasa{\renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  "    \let\btxjvolumeshort\btxvolumeshort\let\Btxjvolumeshort\Btxvolumeshort%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{lamp#1{}}}}\fi%" write$ newline$

  "  \ifx\datecatalan\undefined\else\addto\bibscatalan{\renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  "    \renewcommand{\btxmastthesis}[1]{\protect\foreignlanguage{\biblanguagename}{tesis de m\'{a}ster}}\renewcommand{\btxphdthesis}[1]{\protect\foreignlanguage{\biblanguagename}{tesis doctoral}}%" write$ newline$
  "    \let\btxjvolumeshort\btxvolumeshort\let\Btxjvolumeshort\Btxvolumeshort%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{ap#1{}}}}\fi%" write$ newline$

  "  \ifx\datecroatian\undefined\else\addto\bibscroatian{\renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  "    \renewcommand{\btxmastthesis}[1]{\protect\foreignlanguage{\biblanguagename}{magistarski rad}}\renewcommand{\btxphdthesis}[1]{\protect\foreignlanguage{\biblanguagename}{disertacija}}%" write$ newline$
  "    \def\btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{god#1{}}}\def\Btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{God#1{}}}%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{dod#1{}}}}\fi%" write$ newline$

  "  \ifx\dateczech\undefined\else\addto\bibsczech{\renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  "    \def\btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{ro\v{c}#1{}}}\def\Btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{Ro\v{c}#1{}}}%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{dod#1{}}}}\fi%" write$ newline$

  "  \ifx\datedanish\undefined\else\addto\bibsdanish{\renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  "    \renewcommand{\btxmastthesis}[1]{\protect\foreignlanguage{\biblanguagename}{speciale}}%" write$ newline$
  "    \def\Btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{\AA rg#1{}}}\def\Btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{\aa rg#1{}}}%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{bil#1{}}}}\fi%" write$ newline$

  "  \ifx\datedutch\undefined\else\addto\bibsdutch{\renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  "    \def\btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{jrg#1{}}}\def\Btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{Jrg#1{}}}%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{b\ijl#1{}}}}\fi%" write$ newline$

  "  \ifx\dateesperanto\undefined\else\addto\bibsesperanto{\renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  "    \let\btxjvolumeshort\btxvolumeshort\let\Btxjvolumeshort\Btxvolumeshort%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{ap#1{}}}}\fi%" write$ newline$

  "  \ifx\datefrench\undefined\else\addto\bibsfrench{\renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  "    \renewcommand{\btxmastthesis}[1]{\protect\foreignlanguage{\biblanguagename}{m\'emoire de ma\^itrise}}\renewcommand{\btxphdthesis}[1]{\protect\foreignlanguage{\biblanguagename}{th\`ese de doctorat}}%" write$ newline$
  "    \def\btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{vol#1{}}}\def\Btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{Vol#1{}}}%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{ann#1{}}}}\fi%" write$ newline$

  "  \ifx\dategalician\undefined\else\addto\bibsgalician{\renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  "    \renewcommand{\btxmastthesis}[1]{\protect\foreignlanguage{\biblanguagename}{tese de licenciatura}}\renewcommand{\btxphdthesis}[1]{\protect\foreignlanguage{\biblanguagename}{tese de doutoramento}}%" write$ newline$
  "    \let\btxjvolumeshort\btxvolumeshort\let\Btxjvolumeshort\Btxvolumeshort%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{ap#1{}}}}\fi%" write$ newline$

  "  \ifx\dategerman\undefined\else\addto\bibsgerman{\renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  "    \renewcommand{\btxinshort}[1]{\protect\foreignlanguage{\biblanguagename}{in}}\renewcommand{\Btxinshort}[1]{\protect\foreignlanguage{\biblanguagename}{In}}%" write$ newline$
  "    \def\btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{Jg#1{}}}\def\Btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{Jg#1{}}}%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{Anh#1{}}}}\fi%" write$ newline$

  "  \ifx\dategreek\undefined\else\addto\bibsgreek{\renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\kai}}%" write$ newline$
  "    \renewcommand{\btxmastthesis}[1]{\protect\foreignlanguage{\biblanguagename}{metaptuqiak'h ergas'ia}}\renewcommand{\btxphdthesis}[1]{\protect\foreignlanguage{\biblanguagename}{didaktorik'h diatrib'h}}%" write$ newline$
  "    \def\btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{'et#1{}}}\def\Btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{'Et#1{}}}%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{par#1{}}}}\fi%" write$ newline$

  "  \ifx\dateitalian\undefined\else\addto\bibsitalian{\renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  "    \let\btxjvolumeshort\btxvolumeshort\let\Btxjvolumeshort\Btxvolumeshort%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{app#1{}}}}\fi%" write$ newline$

  "  \ifx\datenorsk\undefined\else\addto\bibsnorsk{\renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  "    \renewcommand{\btxmastthesis}[1]{\protect\foreignlanguage{\biblanguagename}{masteroppgave}}%" write$ newline$
  "    \def\btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{vol#1{}}}\def\Btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{Vol#1{}}}%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{till#1{}}}}\fi%" write$ newline$

  "  \ifx\dateportuguese\undefined\else\addto\bibsportuguese{\renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  "    \renewcommand{\btxmastthesis}[1]{\protect\foreignlanguage{\biblanguagename}{tese de mestrado}}\renewcommand{\btxphdthesis}[1]{\protect\foreignlanguage{\biblanguagename}{tese de doutoramento}}%" write$ newline$
  "    \let\btxjvolumeshort\btxvolumeshort\let\Btxjvolumeshort\Btxvolumeshort%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{ap#1{}}}}\fi%" write$ newline$

  "  \ifx\dateromanian\undefined\else\addto\bibsromanian{\renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  "    \renewcommand{\btxmastthesis}[1]{\protect\foreignlanguage{\biblanguagename}{tez\~{a} de masterat}}\renewcommand{\btxphdthesis}[1]{\protect\foreignlanguage{\biblanguagename}{tez\~{a} de doctorat}}%" write$ newline$
  "    \def\btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{an}}\def\Btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{An}}%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{an#1{}}}}\fi%" write$ newline$

  "  \ifx\daterussian\undefined\else\addto\bibsrussian{%" write$ newline$
  "    \renewcommand{\btxmastthesis}[1]{\protect\foreignlanguage{\biblanguagename}{\IeC {\cyrd }\IeC {\cyri }\IeC {\cyrp }\IeC {\cyrl }\IeC {\cyro }\IeC {\cyrm } \IeC {\cyrm }\IeC {\cyra }\IeC {\cyrg }\IeC {\cyri }\IeC {\cyrs }\IeC {\cyrt }\IeC {\cyrr }\IeC {\cyra }}}%" write$ newline$
  "    \renewcommand{\btxphdthesis}[1]{\protect\foreignlanguage{\biblanguagename}{\IeC {\cyrk }\IeC {\cyra }\IeC {\cyrn }\IeC {\cyrd }\IeC {\cyri }\IeC {\cyrd }\IeC {\cyra }\IeC {\cyrt }\IeC {\cyrs }\IeC {\cyrk }\IeC {\cyra }\IeC {\cyrya } \IeC {\cyrd }\IeC {\cyri }\IeC {\cyrs }\IeC {\cyrs }\IeC {\cyre }\IeC {\cyrr }\IeC {\cyrt }\IeC {\cyra }\IeC {\cyrc }\IeC {\cyri }\IeC {\cyrya }}}%" write$ newline$
  "    \let\btxjvolumeshort\btxvolumeshort\let\Btxjvolumeshort\Btxvolumeshort%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{\cryp\cyrr#1{}}}}\fi%" write$ newline$

  "  \ifx\dateserbian\undefined\else\addto\bibsserbian{renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  "    \renewcommand{\btxinshort}[1]{\protect\foreignlanguage{\biblanguagename}{u}}\renewcommand{\Btxinshort[1]{\protect\foreignlanguage{\biblanguagename}{U}}}%" write$ newline$
  "    \renewcommand{\btxmastthesis}[1]{\protect\foreignlanguage{\biblanguagename}{tez\~{a} de masterat}}\renewcommand{\btxphdthesis}[1]{\protect\foreignlanguage{\biblanguagename}{tez\~{a} de doctorat}}%" write$ newline$
  "    \def\btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{god#1{}}}\def\Btxjvolumeshort#1{\protect\foreignlanguage{\biblanguagename}{God#1{}}}%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{dod#1{}}}}\fi%" write$ newline$

  "  \ifx\datespanish\undefined\else\addto\bibsspanish{\renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  "    \renewcommand{\btxmastthesis}[1]{\protect\foreignlanguage{\biblanguagename}{tesis de maestr\'ia}}\renewcommand{\btxphdthesis}[1]{\protect\foreignlanguage{\biblanguagename}{tesis doctoral}}%" write$ newline$
  "    \let\btxjvolumeshort\btxvolumeshort\let\Btxjvolumeshort\Btxvolumeshort%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{ap#1{}}}}\fi%" write$ newline$

  "  \ifx\dateswedish\undefined\else\addto\bibsswedish{\renewcommand{\btxandshort}[1]{\protect\foreignlanguage{\biblanguagename}{\&}}%" write$ newline$
  "    \let\btxjvolumeshort\btxvolumeshort\let\Btxjvolumeshort\Btxvolumeshort%" write$ newline$
  "    \def\btxappendicesshort#1{\protect\foreignlanguage{\biblanguagename}{bil#1{}}}}\fi%" write$ newline$

  "  \ifbbbbfixlanguage\selectbiblanguage{\biblanguagename}\fi%" write$ newline$ % we added to the language definitions, but we need to do a reload to ensure the additions are in effect
}

EXECUTE {begin.bib}

EXECUTE {init.state.consts}

ITERATE {call.type$}

FUNCTION {end.bib}
{ newline$
  "\end{thebibliography}" write$ newline$
}

EXECUTE {end.bib}
