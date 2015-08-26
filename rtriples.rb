#!/usr/bin/env ruby
require 'sinatra'
require 'rack-cache'
require 'rethinkdb'
include RethinkDB::Shortcuts
include ERB::Util

use Rack::Cache

# HTTP cache headers
#  Cache-Control:public, must-revalidate, max-age=600
#  Expires: now + 10min
before do
  expires 600, :public, :must_revalidate
end

# DEBUG
if settings.development?
  before do
    puts '[Params]'
    p params
  end
end

conn = r.connect(:db => 'rtriples')
table_name = '100'

# set :server, 'thin'

get '/' do
  # get params or default values
  @s = params[:s]
  @p = params[:p]
  @o = params[:o]
  type = params[:type] || 'uri'
  limit = params[:limit] ? params[:limit].to_i : 10
  format = params[:format] || 'html'

  # LANG: allowed only if type is literal
  @lang = params[:lang] if type == 'literal' && params[:lang]
  # DATATYPE: allowed only if type is typed-literal
  @datatype = params[:datatype] if type == 'typed-literal' && params[:datatype]

  unless @s
    # subject is not set

    @subject = r.table(table_name)
    @subject = @subject.filter { |f|
      f['predicate']['value'].eq(@p)
    } if @p
    @subject = @subject.filter { |f|
      f['object']['value'].eq(@o)
    } if @o
    @subject = @subject.filter { |f|
      f['object']['type'].eq(type)
    }
    @subject = @subject.filter { |f|
      f['object']['lang'].eq(@lang)
    } if @lang
    @subject = @subject.filter { |f|
      f['object']['datatype'].eq(@datatype)
    } if @datatype
    if format == 'json'
      @subject = @subject.without('id')
    else
      @subject = @subject['subject']['value']
    end
    @subject = @subject.limit(limit).run(conn).to_a
  end

  unless @p
    # predicate is not set

    @predicate = r.table(table_name)
    @predicate = @predicate.filter { |f|
      f['subject']['value'].eq(@s)
    } if @s
    @predicate = @predicate.filter { |f|
      f['object']['value'].eq(@o)
    } if @o
    @predicate = @predicate.filter { |f|
      f['object']['type'].eq(type)
    }
    @predicate = @predicate.filter { |f|
      f['object']['lang'].eq(@lang)
    } if @lang
    @predicate = @predicate.filter { |f|
      f['object']['datatype'].eq(@datatype)
    } if @datatype
    if format == 'json'
      @predicate = @predicate.without('id')
    else
      @predicate = @predicate['predicate']['value']
    end
    @predicate = @predicate.limit(limit).run(conn).to_a
  end

  unless @o
    # object is not set

    @object = r.table(table_name)
    @object = @object.filter { |f|
      f['subject']['value'].eq(@s)
    } if @s
    @object = @object.filter { |f|
      f['predicate']['value'].eq(@p)
    } if @p
    @object = @object.filter { |f|
      f['object']['type'].eq(type)
    }
    @object = @object.filter { |f|
      f['object']['lang'].eq(@lang)
    } if @lang
    @object = @object.filter { |f|
      f['object']['datatype'].eq(@datatype)
    } if @datatype
    if format == 'json'
      @object = @object.without('id')
    else
      @object = @object['object']['value']
    end
    @object = @object.limit(limit).run(conn).to_a
  end

  if @s and @p and @o
    # returns all if subject, predicate and object set

    @subject = r.table(table_name).filter { |f|
      f['subject']['value'].eq(@s)
    }.filter { |f|
      f['object']['type'].eq(type)
    }
    @subject = @subject.filter { |f|
      f['object']['lang'].eq(@lang)
    } if @lang
    @subject = @subject.filter { |f|
      f['object']['datatype'].eq(@datatype)
    } if @datatype
    if format == 'json'
      @subject = @subject.without('id')
    else
      @subject = @subject['subject']['value']
    end
    @subject = @subject.limit(limit).run(conn).to_a

    @predicate = r.table(table_name).filter { |f|
      f['predicate']['value'].eq(@p)
    }.filter { |f|
      f['object']['type'].eq(type)
    }
    @predicate = @predicate.filter { |f|
      f['object']['lang'].eq(@lang)
    } if @lang
    @predicate = @predicate.filter { |f|
      f['object']['datatype'].eq(@datatype)
    } if @datatype
    if format == 'json'
      @predicate = @predicate.without('id')
    else
      @predicate = @predicate['predicate']['value']
    end
    @predicate = @predicate.limit(limit).run(conn).to_a

    @object = r.table(table_name).filter { |f|
      f['object']['value'].eq(@o)
    }.filter { |f|
      f['object']['type'].eq(type)
    }
    @object = @object.filter { |f|
      f['object']['lang'].eq(@lang)
    } if @lang
    @object = @object.filter { |f|
      f['object']['datatype'].eq(@datatype)
    } if @datatype
    if format == 'json'
      @object = @object.without('id')
    else
      @object = @object['object']['value']
    end
    @object = @object.limit(limit).run(conn).to_a
  end

  if @subject
    @size = @subject.size
  elsif @predicate
    @size = @predicate.size
  elsif @object
    @size = @object.size
  end

  case format
    when 'json'
      @subject = [] unless @subject
      @predicate = [] unless @predicate
      @object = [] unless @object

      @result = @subject + @predicate + @object

      content_type 'application/json'
      @result.to_json
    when 'nt'
      @lang || @datatype ? @quotes = true : false
      content_type 'application/n-triples'
      attachment 'triples.nt'
      erb :ntriples
    when 'csv'
      content_type 'application/csv'
      attachment 'triples.csv'
      erb :csv
    when 'txt'
      content_type 'text/plain'
      attachment 'triples.txt'
      erb :txt
    else
      erb :html
  end

end