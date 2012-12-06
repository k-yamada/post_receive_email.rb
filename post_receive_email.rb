# -*- encoding: utf-8 -*-
require 'net/smtp'
require 'kconv'
require 'cgi'
require 'pp'

def sendmail(from, to, subject, content, host = "localhost", port = 25)
  body = <<EOT
From: #{from}
To: #{to.join(",\n ")}
Subject: #{subject.tojis.force_encoding("US-ASCII")}
Date: #{Time::now.strftime("%a, %d %b %Y %X %z")}
Mime-Version: 1.0
Content-Type: text/html; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit

#{content.tojis.force_encoding("US-ASCII")}
EOT

  Net::SMTP.start(host, port) do |smtp|
    smtp.send_mail body, from, to
  end
end

def escape_html(html)
  CGI::escapeHTML(html).gsub(/ /, '&nbsp;')
end

def whatchanged(oldrev, newrev)
  result = `git whatchanged #{oldrev}..#{newrev}`
  escape_html(result).gsub(/\n/, '</br>')
end

def add_color(line, color)
  "<font color='#{color}'>#{line}</font>"
end

def diff_patch(oldrev, newrev)
  difflist = `git diff-tree --stat --find-copies-harder -p #{oldrev}..#{newrev}`.split("\n")
  result = ""
  difflist.each do |line|
    line = escape_html(line)
    if /^-.*$/ =~ line
      line = add_color(line, "red")
    elsif /^\+.*$/ =~ line
      line = add_color(line, "green")
    elsif /^@@.*$/ =~ line
      line = add_color(line, "steelblue")
    end
    result << line + "</br>"
  end
  result
end

def get_header(ref)
  header = <<-EOF
  <p>
  ref      : #{ref}</br>
  </p>
  EOF
  header
end

def get_body(rev_list)
  body = ""
  rev_list.each do |onerev|
    pre_onerev = "#{onerev}^"
    body << "<p>"
    body << "============================================</br>"
    body << "  <b>[whatchanged]</b></br>"
    body << "  #{whatchanged(pre_onerev, onerev)}"
    body << "  </br></br>"
    body << "  <b>[diff]</b></br>"
    body << "  #{diff_patch(pre_onerev, onerev)}"
    body << "</p>"
  end
  body
end

oldrev = ARGV[0]
newrev = ARGV[1]
ref    = ARGV[2]
subject= ARGV[3]
from   = ARGV[4]
to     = ARGV[5].split(",")

rev_spec = "#{oldrev}..#{newrev}"
rev_list = `git rev-list --all #{rev_spec}`.split

htmlcontent = <<-EOF
<!DOCTYPE html>
<html>
  <head>
    <meta content="text/html; charset=UTF-8" http-equiv="Content-Type" />
  </head>
  <body>
    <h1>git update</h1>
    #{get_header(ref)}
    #{get_body(rev_list)}
  </body>
</html>
EOF

sendmail(from, to, subject, htmlcontent)
