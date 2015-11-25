class ApiV1 < Grape::API
  version 'v1', using: :path
  format :json
  helpers V1Helpers
  formatter :json, PrettyJSON

  include Grape::Kaminari

  paginate per_page: 20, max_per_page: 100, offset: false

  get :councillors do
    people = Person.all
    paginated_people = paginate(Kaminari.paginate_array(people))

    councillors_response(paginated_people)
  end

  namespace :councillors do
    route_param :id do
      get do
        councillor_response Person.find_by_uuid(params[:id])
      end

      get :votes do
        Person.find_by_uuid(params[:id]).person_votes.limit(20)
      end

      get :vote_events do
        Person.find_by_uuid(params[:id]).vote_events.limit(20)
      end
    end
  end

  get :vote_events do
    paginated = paginate(Kaminari.paginate_array(VoteEvent.all))

    vote_events_response(paginated)
  end

  namespace :vote_events do
    route_param :id do
      get do
        vote_event_response VoteEvent.find_by_uuid(params[:id])
      end

      get :votes do
        person_votes = VoteEvent.find_by_uuid(params[:id]).person_votes
        paginated = paginate_array(person_votes)

        person_votes_response paginated
      end

      get :councillors do
        people = VoteEvent.find_by_uuid(params[:id]).people
        paginated = paginate_array(people)

        councillors_response paginated
      end
    end
  end

  get :bills do
    paginated = paginate_array(Bill.in_toronto)

    bills_response paginated
  end

  namespace :bills do
    route_param :id do
      get do
        bill_response Bill.find_by_uuid(params[:id])
      end

      get :vote_events do
        Bill.find_by_uuid(params[:id]).vote_events.limit(20)
      end

      get :councillors do
        Bill.find_by_uuid(params[:id]).people.limit(20)
      end

      get :votes do
        Bill.find_by_uuid(params[:id]).person_votes.limit(20)
      end
    end
  end

  get :sessions do
    LegislativeSession.in_toronto.limit(20)
  end

  namespace :sessions do
    route_param :id do
      get do
        LegislativeSession.find(params[:id])
      end

      get :bills do
        LegislativeSession.find(params[:id]).bills.limit(20)
      end
    end
  end

end
