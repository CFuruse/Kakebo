class KakebosController < ApplicationController
  before_action :signed_in_user
  RAILS_ROOT = Rails.root.to_s
  IMAGE_PATH = RAILS_ROOT + "/app/assets/images/"
  helper_method :sort_column, :sort_direction

  def new
    @kakebo = Kakebo.new
  end

  def create
    begin
      upload_file = kakebo_params[:scan]
      regist_params = {}
      regist_params = kakebo_params
      name = upload_file.original_filename
      regist_params[:scan] =  IMAGE_PATH + name
    rescue
      @kakebo = Kakebo.new(kakebo_params)
      if @kakebo.save
        flash[:success] = "登録が正常に完了しました"
        redirect_to new_kakebo_path
      else
        render action: 'new'
      end
      return
    end
    if !['.jpg', '.png', '.gif'].include?(File.extname(name).downcase)
      flash[:error] = 'jpg, png, gifのみアップロードできます'
      redirect_to new_kakebo_path
    elsif upload_file.size > 5.megabyte
      flash[:error] = 'アップロードできるファイルのサイズは5MBまでです'
      redirect_to new_kakebo_path
    else
      File.open(regist_params[:scan], "wb") {|f| f.write(upload_file.read)}
      @kakebo = Kakebo.new(regist_params)
      if @kakebo.save
        flash[:success] = "登録が正常に完了しました"
        redirect_to new_kakebo_path
      else
        render action: 'new'
      end
    end
  end

  def index
    @kakebo = Kakebo.new
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
      食費: 0, 家賃: 0, 保険: 0, 娯楽: 0,
      日用品: 0, 洋服: 0, 医療費: 0, 交通費: 0,
      ガソリン: 0, 光熱費: 0, 子供: 0, その他出費: 0,
      生活費: 0, その他収入: 0
    }
    @kind_hash.each {|key, val|
      @kind_hash[key] = @kakebos.where(kind: key).count
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

  def show
    @kakebo = Kakebo.find(params[:id])
  end

  def edit
    @kakebo = Kakebo.find(params[:id])
  end

  def update
    @kakebo = Kakebo.find(params[:id])
    begin
      upload_file = kakebo_params[:scan]
      regist_params = {}
      regist_params = kakebo_params
      name = upload_file.original_filename
      regist_params[:scan] = IMAGE_PATH + name
    end
    if !['.jpg', '.png', '.gif'].include?(File.extname(name).downcase)
      flash[:error] = 'jpg, pdng, gifのみアップロードできます'
      redirect_to edit_kakebo_path(@kakebo)
    elsif upload_file.size > 5.megabyte
      flash[:error] = 'アップロードできるファイルのサイズは5MBまでです'
      redirect_to edit_kakebo_path(@kakebo)
    else
      File.open(regist_params[:scan], "wb") {|f| f.write(upload_file.read)}
      if @kakebo.update_attributes(regist_params)
        flash[:success] = "更新が完了しました"
        redirect_to @kakebo
      else
        render action: 'edit'
      end
    end
  end

  def destroy
    Kakebo.find(params[:id]).destroy
    flash[:success] = "削除しました"
    redirect_to kakebos_path
  end

  private

    def kakebo_params
      params.require(:kakebo).permit(:date, :komoku, :shunyu, :shishutsu,
                                     :kind, :scan,   :scanfile)
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

end
