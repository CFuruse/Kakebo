class KakebosController < ApplicationController
  before_action :signed_in_user
  RAILS_ROOT = Rails.root.to_s
  IMAGE_PATH = RAILS_ROOT + "/app/assets/images/"
  helper_method :sort_column, :sort_direction

  def new
    @kakebo = Kakebo.new
  end

  def create
    register_data(kakebo_params)
  end

  def index
    @kakebo = Kakebo.new
    @q = Kakebo.ransack
  end

  def search_month
    event  = params[:kakebo]
    @year  = params[:kakebo][:"date(1i)"]
    @month = params[:kakebo][:"date(2i)"]
    search = Date.civil(
                 event[:"date(1i)"].to_i,
                 event[:"date(2i)"].to_i,
                 event[:"date(3i)"].to_i
                 )
    # 選択月のデータを収集
    @kakebos = Kakebo.all.order(sort_column + ' ' + sort_direction)
    @kakebos = @kakebos.where(
      date:
      search.beginning_of_month..search.end_of_month
      ).paginate(page: params[:page], :per_page => 50).order(:id)
    # 収入、支出、収支を収集
    @shunyu_sum = Kakebo.where(
      date:
      search.beginning_of_month..search.end_of_month
    ).sum(:shunyu)
    @shishutsu_sum = Kakebo.where(
      date:
      search.beginning_of_month..search.end_of_month
    ).sum(:shishutsu)
    @shushi = @shunyu_sum - @shishutsu_sum
    # 各種類の数量を収集
    @kind_hash = {
      食費: 0, 携帯電話: 0, 家賃: 0, 保険: 0, 娯楽: 0,
      日用品: 0, 洋服: 0, 医療費: 0, 交通費: 0,
      ガソリン: 0, 光熱費: 0, 子供: 0, その他出費: 0,
      生活費: 0, その他収入: 0
    }
    @kind_hash.each {|key, val|
      @kind_hash[key] = @kakebos.where(
        kind: key,
        date: search.beginning_of_month..search.end_of_month
        ).sum(:shishutsu)
    }
    # 選択月の毎日のデータを収集
    @shunyu_each = Array.new
    @shishutsu_each = Array.new
    @shushi_each = Array.new
    count = 0
    daycount = search.end_of_month.day   # 検索月の日数
    while count < daycount
      @shunyu_each.push(
        [
          search,
          Kakebo.where(
            date:
            search
          ).sum(:shunyu)
        ]
      )
      @shishutsu_each.push(
        [
          search,
          Kakebo.where(
            date:
            search
          ).sum(:shishutsu)
        ]
      )
      search = search.tomorrow
      count += 1
    end
  end

  def search_year
    jan = 1
    dec = 12
    event  = params[:kakebo]
    @year  = params[:kakebo][:"date(1i)"]
    search = Date.civil(
                 event[:"date(1i)"].to_i,
                 jan,
                 event[:"date(3i)"].to_i
                 )
    last_day = Date.civil(
                 event[:"date(1i)"].to_i,
                 dec,
                 event[:"date(3i)"].to_i
                 )

    # 年単位収支用
    @shunyu_sum_year = Kakebo.where(
      date:
      search.beginning_of_month..last_day.end_of_month
    ).sum(:shunyu)
    @shishutsu_sum_year = Kakebo.where(
      date:
      search.beginning_of_month..last_day.end_of_month
    ).sum(:shishutsu)
    @shushi_year = @shunyu_sum_year - @shishutsu_sum_year

    # 月単位
    @shushi_array = Array.new
    @year_array   = Array.new
    month = jan
    until month > 12
      @shunyu_sum = Kakebo.where(
        date:
        search.beginning_of_month..search.end_of_month
      ).sum(:shunyu)
      @shishutsu_sum = Kakebo.where(
        date:
        search.beginning_of_month..search.end_of_month
      ).sum(:shishutsu)
      @shushi = @shunyu_sum - @shishutsu_sum
      @year_array.push(
        @shunyu_sum,
        @shishutsu_sum,
        @shushi
      )
      @shushi_array.push(@year_array)
      # initialize
      month += 1
      @year_array = Array.new
      search = search.next_month
    end
  end

  def search_detail
    @q = Kakebo.all.order(
           sort_column + ' ' + sort_direction
         ).ransack(params[:q])
    @kakebos = @q
               .result
               .paginate(page: params[:page], :per_page => 50).order(:id)
  end

  def show
    @kakebo = Kakebo.find(params[:id])
  end

  def edit
    @kakebo = Kakebo.find(params[:id])
  end

  def update
    update_data(kakebo_params)
  end

  def destroy
    Kakebo.find(params[:id]).destroy
    flash[:success] = "削除しました"
    redirect_to kakebos_path
  end

  private

    def kakebo_params
      params.require(:kakebo).permit(:date, :komoku, :shunyu, :shishutsu,
                                     :kind, :scan,   :scanfile, :bikou)
    end

    def file_params
      params.require(:kakebo).permit(:scan, :scanfile)
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def sort_column
      Kakebo.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def search_params
      search_conditions = %i(
        id_eq date_gteq(1i) date_gteq(2i) date_gteq(3i)
        date_lteq(1i) date_lteq(2i) date_lteq(3i) komoku_cont
        shunyu_lteq shunyu_gteq shishutsu_lteq shishutsu_gteq
        kind_eq
      )
      params.require(:q).permit(search_conditions)
    end
end
