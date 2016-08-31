FROM elixir:1.2.4

RUN apt-get update && apt-get install -y git build-essential erlang-dev
RUN mix local.hex --force
RUN mix local.rebar --force

ADD . /code/fylerx
WORKDIR /code/fylerx

RUN useradd -m deplo
RUN chown -R deplo /code/fylerx

ENV MIX_ENV dev 
RUN mix deps.get --only $MIX_ENV
RUN mix compile

ENV PORT 4001

CMD ["mix", "phoenix.server"] 



