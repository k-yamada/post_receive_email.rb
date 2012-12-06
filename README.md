=====================
post_receive_email.rb
=====================

Introduction
============

This is a Git post-receive hook script written in Ruby that will send
emails when commits are pushed to the repository. It has no
dependencies other than Ruby and Git.

Usage
======
Create a Git post-receive hook script to your git backup repository.

    # /path/to/sample-prj.git/hooks/post-receive
    # send mail
    # ---------
    read oldrev newrev refname
    # ruby /path/to/post_receive_email.rb <oldrev> <newrev> <refname> <subject> <from> <to1,to2>
    ruby /path/to/post_receive_email.rb $oldrev $newrev $refname "[git update] sample-prj" from@gmail.com to1@gmail.com,to2@gmail.com


Licence
=======

MIT License.
