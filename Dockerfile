FROM ruby:2.5

WORKDIR /srv/app
COPY Gemfile* ./
RUN rm Gemfile.lock
RUN bundle install --jobs 20 --retry 5

COPY . .
COPY ./sample.txt ./file

CMD ["ruby", "parser.rb", "file"]