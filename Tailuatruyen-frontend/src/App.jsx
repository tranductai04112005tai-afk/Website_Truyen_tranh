function Panel({ title, children }) { return <section className="panel"><p className="eyebrow">{title}</p>{children}</section> }
import { useEffect, useMemo, useState } from 'react'
import {
  ArrowRight, BookOpen, BookOpenCheck, CheckCircle2, ChevronLeft, ChevronRight, CircleUserRound,
  Clock3, Compass, Crown, Eye, Gem, Heart, Library, Menu, Plus, QrCode, Search,
  ShieldCheck, Sparkles, Star, Wallet, X, Zap
} from 'lucide-react'
import { api } from './api'

const fallbackStories = [
  { id: 1, title: 'Kẻ Đánh Cắp Ánh Trăng', author: 'Tạ Vũ', description: 'Một kẻ trộm ký ức bước vào thành phố không có bình minh.', coverImage: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=620&q=80', status: 'ACTIVE', chapters: 86 },
  { id: 2, title: 'Sau Cơn Mưa Ở Thành Nam', author: 'Lam Nguyệt', description: 'Những lá thư cũ, một lời hẹn và mùa hè chưa từng kết thúc.', coverImage: 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=620&q=80', status: 'ACTIVE', chapters: 42 },
  { id: 3, title: 'Tinh Hà Rơi Trên Vai', author: 'Mộc Miên', description: 'Khi các vì sao rơi xuống, cô phải chọn giữa quê hương và tự do.', coverImage: 'https://images.unsplash.com/photo-1462331940025-496dfbfc7564?auto=format&fit=crop&w=620&q=80', status: 'ACTIVE', chapters: 119 },
  { id: 4, title: 'Nhật Ký Của Kẻ Mộng Du', author: 'Nhã Khanh', description: 'Một cô gái tỉnh dậy mỗi sáng ở một nơi chưa từng đặt chân tới.', coverImage: 'https://images.unsplash.com/photo-1500534623283-312aade485b7?auto=format&fit=crop&w=620&q=80', status: 'ACTIVE', chapters: 27 },
  { id: 5, title: 'Vạn Kiếm Quy Tông', author: 'Đường Mặc', description: 'Thiếu niên vô danh trở lại giang hồ sau mười năm biệt tích.', coverImage: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=620&q=80', status: 'ACTIVE', chapters: 204 },
  { id: 6, title: 'Tiệm Sách Cuối Con Dốc', author: 'An Nhiên', description: 'Nơi mỗi cuốn sách đều giữ lại một người mà ta từng yêu.', coverImage: 'https://images.unsplash.com/photo-1526243741027-444d633d7365?auto=format&fit=crop&w=620&q=80', status: 'ACTIVE', chapters: 18 }
]

const genres = ['Tất cả', 'Tiên hiệp', 'Ngôn tình', 'Đô thị', 'Huyền huyễn', 'Trinh thám', 'Phiêu lưu', 'Cổ đại']

// Bỏ dấu tiếng Việt để tìm kiếm không phân biệt có dấu/không dấu
// (VD: gõ "ta vu" vẫn tìm ra tác giả "Tạ Vũ") - đây là nguyên nhân chính khiến tìm theo tác giả "không ra kết quả"
function normalizeVN(value) {
  return (value || '')
    .normalize('NFD')
    .replace(/\p{Diacritic}/gu, '')
    .replace(/đ/g, 'd').replace(/Đ/g, 'D')
    .toLowerCase()
}

function App() {
  const [stories, setStories] = useState(fallbackStories)
  const [search, setSearch] = useState('')
  const [activeGenre, setActiveGenre] = useState('Tất cả')
  const [selectedStory, setSelectedStory] = useState(null)
  const [chapters, setChapters] = useState([])
  const [reader, setReader] = useState(null)
  const [readerIndex, setReaderIndex] = useState(-1)
  const [readerContent, setReaderContent] = useState('')
  const [readerError, setReaderError] = useState('')
  const [loginOpen, setLoginOpen] = useState(false)
  const [account, setAccount] = useState(() => JSON.parse(localStorage.getItem('tailuatruyen_account') || 'null'))
  const [toast, setToast] = useState('')
  const [loading, setLoading] = useState(false)
  const [route, setRoute] = useState(window.location.hash.slice(1) || '/')
  const [page, setPage] = useState(0)
  const [totalPages, setTotalPages] = useState(1)
  const [searchFocused, setSearchFocused] = useState(false)
  const googleClientId = import.meta.env.VITE_GOOGLE_CLIENT_ID || ''

  useEffect(() => {
    const onHashChange = () => setRoute(window.location.hash.slice(1) || '/')
    window.addEventListener('hashchange', onHashChange)
    return () => window.removeEventListener('hashchange', onHashChange)
  }, [])

  useEffect(() => {
    if (route.startsWith('/admin')) return undefined
    let alive = true
    const timer = setTimeout(() => {
      api.stories(page, 12, search.trim()).then((data) => {
        if (alive && data?.content) {
          setStories(data.content.length ? data.content : fallbackStories)
          setTotalPages(data.totalPages || 1)
        }
      }).catch(() => {})
    }, 300) // debounce 300ms cho tính năng search
    return () => { alive = false; clearTimeout(timer) }
  }, [route, page, search])

  useEffect(() => {
    if (!toast) return undefined
    const timer = setTimeout(() => setToast(""), 2800)
    return () => clearTimeout(timer)
  }, [toast])


  const heroStories = useMemo(() => stories.slice(0, 5), [stories])
  const [heroIndex, setHeroIndex] = useState(0)
  useEffect(() => {
    if (heroStories.length <= 1) return undefined
    const timer = setInterval(() => setHeroIndex((current) => (current + 1) % heroStories.length), 5000)
    return () => clearInterval(timer)
  }, [heroStories.length])
  useEffect(() => { setHeroIndex(0) }, [heroStories.length])
  const heroStory = heroStories[heroIndex] || stories[0]

  const openStory = async (story) => {
    setSelectedStory(story)
    setChapters([])
    try {
      const [detail, chapterData] = await Promise.all([api.story(story.id), api.chapters(story.id)])
      setSelectedStory(detail || story)
      setChapters(chapterData?.content || [])
    } catch {
      setChapters(Array.from({ length: story.chapters || 12 }, (_, index) => ({
        id: `${story.id}-${index + 1}`, chapterNumber: index + 1, title: `Chuong ${index + 1}`, isFree: index < 5, priceInSilver: index < 5 ? 0 : 50, visible: true
      })))
    }
    window.scrollTo({ top: 0, behavior: "smooth" })
  }

  const openChapter = async (chapter) => {
    const index = chapters.findIndex((item) => item.id === chapter.id)
    setReader(chapter)
    setReaderIndex(index >= 0 ? index : -1)
    setReaderContent("")
    setReaderError("")
    const price = Number(chapter.priceInSilver || 0)
    const needsPayment = !chapter.isFree && price > 0
    const hasVipAccess = account?.role === "ADMIN" || account?.role === "VIP_MEMBER" || account?.isVip === true

    if (needsPayment && !hasVipAccess) {
      if (!account) {
        setReaderError("Ban can dang nhap de doc chuong nay.")
        return
      }
      const balance = Number(account.silverBalance || 0)
      if (balance < price) {
        setReaderError(`So du khong du. Chuong nay can ${price} Silver de mo.`)
        return
      }
      const confirmed = window.confirm(`Chuong nay can ${price} Silver. Xac nhan dung Silver de doc?`)
      if (!confirmed) {
        setReader(null)
        setToast("Ban da huy mo khoa chuong.")
        return
      }
    }

    try {
      const result = await api.chapterContent(chapter.id)
      setReaderContent(result.content)
      if (needsPayment && !hasVipAccess) {
        api.userMe().then(me => {
          if (me?.silverBalance !== undefined) {
            const updatedAccount = { ...account, silverBalance: Number(me.silverBalance) }
            setAccount(updatedAccount)
            localStorage.setItem("tailuatruyen_account", JSON.stringify(updatedAccount))
          }
        }).catch(() => {
          const updatedAccount = { ...account, silverBalance: Number(account.silverBalance || 0) - price }
          setAccount(updatedAccount)
          localStorage.setItem("tailuatruyen_account", JSON.stringify(updatedAccount))
        })
        setToast(`Da dung ${price} Silver de mo chuong.`)
      }
    } catch (error) {
      setReaderError(error.message || "Ban can nap Silver de doc chuong nay.")
    }
  }

  const goToAdjacentChapter = (offset) => {
    if (!selectedStory || chapters.length === 0) return
    const nextIndex = readerIndex + offset
    if (nextIndex < 0 || nextIndex >= chapters.length) {
      setToast(offset < 0 ? "Day la chuong dau tien." : "Day la chuong cuoi cung.")
      return
    }
    openChapter(chapters[nextIndex])
  }

  const saveAuth = (result) => {
    const normalizedUser = {
      ...result,
      role: result.role || 'MEMBER',
      displayName: result.displayName || result.email || 'Độc giả',
      silverBalance: Number(result.silverBalance || 0)
    }
    localStorage.setItem('tailuatruyen_token', result.token)
    localStorage.setItem('tailuatruyen_account', JSON.stringify(normalizedUser))
    setAccount(normalizedUser)
    setLoginOpen(false)
    setToast('Chào mừng bạn trở lại thư viện.')
  }

  const handleGoogleCredential = async (response) => {
    if (!response?.credential) return
    setLoading(true)
    try {
      const result = await api.googleLogin(response.credential)
      saveAuth(result)
    } catch (error) {
      setToast(error.message || 'Không thể đăng nhập bằng Google.')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    if (!googleClientId || !window.google?.accounts?.id) return

    window.google.accounts.id.initialize({
      client_id: googleClientId,
      callback: handleGoogleCredential
    })
  }, [googleClientId])

  const handleLogin = async (event) => {
    event.preventDefault()
    setLoading(true)
    const form = new FormData(event.currentTarget)
    const payload = { email: form.get('email'), displayName: form.get('displayName'), silverBalance: 100000 }
    try {
      const result = await api.devLogin(payload)
      saveAuth(result)
    } catch {
      const localAccount = { displayName: payload.displayName || 'Độc giả mới', email: payload.email, role: 'MEMBER', silverBalance: 0 }
      localStorage.setItem('tailuatruyen_account', JSON.stringify(localAccount))
      setAccount(localAccount)
      setLoginOpen(false)
      setToast('Đã vào chế độ xem thử. Backend login chưa sẵn sàng.')
    } finally {
      setLoading(false)
    }
  }

  if (route.startsWith('/admin') && account?.role === 'ADMIN') {
    return <AdminShell account={account} onLogout={() => { localStorage.removeItem('tailuatruyen_account'); localStorage.removeItem('tailuatruyen_token'); setAccount(null); window.location.hash = '/' }} toast={toast} />
  }

  if (route === '/vi') {
    return <WalletPage account={account} setAccount={setAccount} onBack={() => { window.location.hash = '/' }} />
  }

  return (
    <div className="app-shell">
      <header className="site-header">
        <div className="header-inner">
          <button className="brand" onClick={() => { setSelectedStory(null); window.scrollTo({ top: 0, behavior: 'smooth' }) }} aria-label="Về trang chủ">
            <span className="brand-mark"><BookOpen size={20} strokeWidth={2.2} /></span>
            <span><strong>TÀ LỤA</strong><small>TRUYỆN CHỮ</small></span>
          </button>
          <nav className="main-nav" aria-label="Điều hướng chính">
            <a href="#kham-pha"><Compass size={16} /> Khám phá</a>
            <a href="#the-loai"><Library size={16} /> Thể loại</a>
            <a href="#moi-cap-nhat"><Zap size={16} /> Mới cập nhật</a><a href="#/vi">Ví Silver</a>
          </nav>
          <div className="header-actions">
            <div style={{position: 'relative'}}>
              <label className="search-box">
                <Search size={17} />
                <input value={search} onChange={(event) => { setSearch(event.target.value); setPage(0); }} onFocus={() => setSearchFocused(true)} onBlur={() => setTimeout(() => setSearchFocused(false), 200)} placeholder="Tìm truyện, tác giả..." />
                <kbd>/</kbd>
              </label>
              {searchFocused && search.trim() && stories.length > 0 && (
                <div style={{position: 'absolute', top: '100%', left: 0, right: 0, background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: '8px', marginTop: '4px', zIndex: 100, maxHeight: '350px', overflowY: 'auto', boxShadow: '0 4px 12px rgba(0,0,0,0.15)'}}>
                  {stories.map(story => (
                    <div key={story.id} onClick={() => { openStory(story); setSearchFocused(false); }} className="search-dropdown-item" style={{padding: '8px 12px', display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer', borderBottom: '1px solid var(--border)', transition: 'background 0.2s'}}>
                      <img src={story.coverImage} alt="" style={{width: '32px', height: '44px', objectFit: 'cover', borderRadius: '4px'}} />
                      <div style={{display: 'flex', flexDirection: 'column', overflow: 'hidden'}}>
                        <strong style={{fontSize: '13px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis'}}>{story.title}</strong>
                        <small style={{fontSize: '11px', color: 'var(--text-secondary)'}}>{story.author}</small>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
            {account ? <><button className="account-chip" onClick={() => setToast(`Xin chào, ${account.displayName}.`)}><span className="avatar-wrap"><CircleUserRound size={18} />{(account.isVip || account.role === 'VIP_MEMBER') && <span className="vip-avatar-badge">V</span>}</span>{account.displayName}</button>{account.role === 'ADMIN' && <button className="login-link" onClick={() => { window.location.hash = '/admin'; }}>Quản trị</button>}<button className="text-button" onClick={() => { localStorage.removeItem('tailuatruyen_account'); localStorage.removeItem('tailuatruyen_token'); setAccount(null); setToast('Bạn đã đăng xuất.') }}>Thoát</button></> : <button className="login-link" onClick={() => setLoginOpen(true)}>Đăng nhập</button>}
            <button className="mobile-menu" aria-label="Mở menu"><Menu size={21} /></button>
          </div>
        </div>
      </header>

      <main>
        {selectedStory ? <StoryView story={selectedStory} chapters={chapters} onBack={() => setSelectedStory(null)} onChapter={openChapter} account={account} onRequireLogin={() => setLoginOpen(true)} onToast={setToast} /> : <>
          <section className="hero" id="kham-pha">
            <div className="hero-copy">
              <p className="eyebrow"><Sparkles size={15} /> Không gian đọc chọn lọc</p>
              <h1>Đọc chậm lại.<br /><em>Ở lại lâu hơn.</em></h1>
              <p className="hero-lead">Những câu chuyện đáng để bạn tắt thông báo, pha một tách trà và bước vào một thế giới khác.</p>
              <div className="hero-actions"><button className="primary-button" onClick={() => openStory(heroStory)}>Bắt đầu đọc <ArrowRight size={17} /></button><button className="text-button" onClick={() => document.getElementById('moi-cap-nhat')?.scrollIntoView({ behavior: 'smooth' })}>Xem truyện mới <ChevronRight size={16} /></button></div>
              <div className="hero-note"><span className="live-dot" /> 1.284 độc giả đang đọc tối nay</div>
            </div>
            {/* Khối bìa trên cùng tự động chuyển qua lại giữa vài truyện (trước đây luôn cố định 1 truyện đầu tiên) */}
            <div className="hero-book" onClick={() => openStory(heroStory)} style={{ cursor: 'pointer' }}>
              <div className="book-glow" />
              <img key={heroStory.id} src={heroStory.coverImage} alt={heroStory.title} />
              <div className="book-caption"><span>ĐỀ CỬ BIÊN TẬP VIÊN</span><strong>{heroStory.title}</strong><small>{heroStory.author} · {heroStory.chapters || 86} chương</small></div>
              {heroStories.length > 1 && <div className="hero-dots" onClick={(event) => event.stopPropagation()}>
                {heroStories.map((story, index) => <button key={story.id} className={index === heroIndex ? 'active' : ''} aria-label={`Xem truyện ${story.title}`} onClick={() => setHeroIndex(index)} />)}
              </div>}
            </div>
          </section>

          <section className="section trending-section">
            <div className="section-heading"><div><p className="eyebrow">Đọc nhiều nhất</p><h2>Thịnh hành tuần</h2></div><button className="view-all" onClick={() => setToast('Danh sách thịnh hành sẽ được mở rộng trong bản tiếp theo.')}>Xem tất cả <ArrowRight size={15} /></button></div>
            <div className="trending-grid">{stories.slice(0, 3).map((story, index) => <TrendingCard key={story.id} story={story} index={index} onOpen={openStory} />)}</div>
          </section>

          <section className="section update-section" id="moi-cap-nhat">
            <div className="section-heading"><div><p className="eyebrow">Tất cả truyện</p><h2>{search ? 'Kết quả tìm kiếm' : 'Danh sách truyện'}</h2></div><div className="section-arrows" style={{display: 'flex', alignItems: 'center', gap: '10px'}}><button aria-label="Trước" disabled={page === 0} onClick={() => setPage(p => p - 1)}><ChevronLeft size={17} /></button><span style={{fontSize: '14px', fontWeight: 600, color: 'var(--text-secondary)'}}>{page + 1} / {totalPages}</span><button aria-label="Sau" disabled={page >= totalPages - 1} onClick={() => setPage(p => p + 1)}><ChevronRight size={17} /></button></div></div>
            <div className="story-grid">{stories.map((story) => <StoryCard key={story.id} story={story} onOpen={openStory} />)}</div>
          </section>

          <section className="section discovery-band">
            <div className="discovery-copy"><p className="eyebrow"><Crown size={15} /> Góc đề cử</p><h2>Một cuốn sách<br /><em>cho mỗi tâm trạng.</em></h2><p>Không cần biết mình muốn đọc gì. Chỉ cần chọn một cảm giác.</p><button className="outline-button" onClick={() => setToast('Tính năng gợi ý theo tâm trạng đang được chuẩn bị.')}>Khám phá lựa chọn <ArrowRight size={16} /></button></div>
            <div className="mood-list"><Mood icon="☾" title="Muốn trốn khỏi thực tại" desc="Tiên hiệp · Huyền huyễn" color="violet" /><Mood icon="♡" title="Một chút rung động" desc="Ngôn tình · Lãng mạn" color="rose" /><Mood icon="◌" title="Cần một cú twist" desc="Trinh thám · Kinh dị" color="gold" /></div>
          </section>

          <section className="section genre-section" id="the-loai"><div className="section-heading"><div><p className="eyebrow">Tìm theo gu</p><h2>Thể loại</h2></div><button className="view-all">Tất cả thể loại <ArrowRight size={15} /></button></div><div className="genre-pills">{genres.map((genre) => <button key={genre} className={activeGenre === genre ? 'active' : ''} onClick={() => setActiveGenre(genre)}>{genre}</button>)}</div></section>
        </>}
      </main>

      <footer className="site-footer"><div className="footer-brand"><span className="brand-mark"><BookOpen size={20} /></span><div><strong>TÀI LỬA TRUYỆN</strong><p>Đọc một câu chuyện. Giữ lại một thế giới.</p></div></div><div className="footer-links"><a href="#kham-pha">Khám phá</a><a href="#the-loai">Thể loại</a><a href="#moi-cap-nhat">Mới cập nhật</a><a href="#lien-he">Liên hệ</a></div><small>© 2026 Tà Lụa Truyện</small></footer>
      {reader && <Reader chapter={reader} content={readerContent} error={readerError} onClose={() => setReader(null)} onTopup={() => { setReader(null); window.location.hash = '/vi' }} onPrev={() => goToAdjacentChapter(-1)} onNext={() => goToAdjacentChapter(1)} canPrev={readerIndex > 0} canNext={readerIndex >= 0 && readerIndex < chapters.length - 1} />}
      {loginOpen && <LoginModal onClose={() => setLoginOpen(false)} onSubmit={handleLogin} loading={loading} googleClientId={googleClientId} />} 
      {toast && <div className="toast"><BookOpenCheck size={17} /> {toast}</div>}
    </div>
  )
}

function TrendingCard({ story, index, onOpen }) { return <article className="trending-card" onClick={() => onOpen(story)}><span className="rank">0{index + 1}</span><img src={story.coverImage} alt="" /><div className="trending-info"><span className="card-label">{index === 0 ? 'ĐANG ĐƯỢC ĐỌC' : 'TĂNG TRƯỞNG MẠNH'}</span><h3>{story.title}</h3><p>{story.author}</p><div className="meta"><span><Eye size={14} /> {(86 - index * 13) + 'k'} lượt đọc</span><span><BookOpen size={14} /> {story.chapters || 42} chương</span></div></div></article> }
function StoryCard({ story, onOpen }) { return <article className="story-card" onClick={() => onOpen(story)}><div className="cover-wrap"><img src={story.coverImage} alt={story.title} /><span className="new-badge">MỚI</span><button className="heart-button" onClick={(event) => { event.stopPropagation(); }} aria-label="Lưu truyện"><Heart size={16} /></button></div><div className="story-card-info"><h3>{story.title}</h3><p>{story.author || 'Tác giả ẩn danh'}</p><div className="story-meta"><span><Star size={13} fill="currentColor" /> 4.{(indexSafe(story.id) + 4)}</span><span>{story.chapters || '—'} chương</span></div></div></article> }
function indexSafe(value) { return Number(String(value).replace(/\D/g, '').slice(-1)) || 1 }
function Mood({ icon, title, desc, color }) { return <button className={`mood mood-${color}`}><span>{icon}</span><div><strong>{title}</strong><small>{desc}</small></div><ArrowRight size={17} /></button> }
function StoryView({ story, chapters, onBack, onChapter, account, onRequireLogin, onToast }) { return <section className="story-view"><button className="back-link" onClick={onBack}><ChevronLeft size={17} /> Trở về khám phá</button><div className="story-detail"><img className="detail-cover" src={story.coverImage} alt={story.title} /><div className="detail-copy"><p className="eyebrow">HỒ SƠ TRUYỆN</p><h1>{story.title}</h1><p className="detail-author">{story.author || 'Tác giả ẩn danh'}</p><p className="detail-description">{story.description || 'Một câu chuyện đang chờ bạn mở trang đầu tiên.'}</p><div className="detail-stats"><span><strong>{story.chapters || chapters.length || '—'}</strong> chương</span><span><strong>4.8</strong> đánh giá</span><span><strong>Đang ra</strong> trạng thái</span></div><button className="primary-button" onClick={() => chapters[0] && onChapter(chapters[0])}>Đọc chương đầu <BookOpen size={17} /></button></div></div><div className="chapter-panel"><div className="section-heading"><div><p className="eyebrow">Mục lục</p><h2>Danh sách chương</h2></div><span className="chapter-count">{chapters.length || story.chapters || 0} chương</span></div><div className="chapter-list">{chapters.map((chapter) => <button key={chapter.id} onClick={() => onChapter(chapter)}><span>Chương {chapter.chapterNumber}</span><strong>{chapter.title || `Chương ${chapter.chapterNumber}`}</strong>{chapter.isFree ? <small>Miễn phí</small> : <small className="paid">{chapter.priceInSilver || 50} bạc</small>}</button>)}</div></div><CommentsSection storyId={story.id} account={account} onRequireLogin={onRequireLogin} onToast={onToast} /></section> }

function CommentsSection({ storyId, account, onRequireLogin, onToast }) {
  const [comments, setComments] = useState([])
  const [loading, setLoading] = useState(true)
  const [content, setContent] = useState('')
  const [sending, setSending] = useState(false)

  const load = () => {
    setLoading(true)
    api.comments(storyId).then(data => setComments(data?.content || [])).catch(() => setComments([])).finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [storyId])

  const submit = async (event) => {
    event.preventDefault()
    if (!account) { onRequireLogin(); return }
    const text = content.trim()
    if (!text) return
    setSending(true)
    try {
      await api.addComment(storyId, text)
      setContent('')
      load()
      onToast?.('Đã đăng bình luận của bạn.')
    } catch (error) {
      onToast?.(error.message || 'Không thể gửi bình luận lúc này.')
    } finally {
      setSending(false)
    }
  }

  const remove = async (commentId) => {
    try {
      await api.deleteComment(commentId)
      setComments(current => current.filter(item => item.id !== commentId))
      onToast?.('Đã xoá bình luận.')
    } catch (error) {
      onToast?.(error.message || 'Không thể xoá bình luận.')
    }
  }

  const initials = (name) => (name || '?').trim().slice(0, 1).toUpperCase()
  const formatDate = (value) => value ? new Date(value).toLocaleString('vi-VN') : ''

  return <div className="comments-panel">
    <div className="section-heading"><div><p className="eyebrow">Thảo luận</p><h2>Bình luận</h2></div><span className="chapter-count">{comments.length} bình luận</span></div>
    <form className="comment-form" onSubmit={submit}>
      <textarea value={content} onChange={(event) => setContent(event.target.value)} placeholder={account ? 'Chia sẻ cảm nhận của bạn về truyện này...' : 'Đăng nhập để bình luận...'} rows={3} maxLength={2000} />
      <button className="primary-button" type="submit" disabled={sending || !content.trim()}>{sending ? 'Đang gửi...' : 'Gửi bình luận'}</button>
    </form>
    {loading ? <p className="muted">Đang tải bình luận...</p> : comments.length === 0 ? <p className="muted">Chưa có bình luận nào. Hãy là người đầu tiên!</p> : <ul className="comment-list">
      {comments.map(comment => <li key={comment.id} className="comment-item">
        <span className="comment-avatar">{initials(comment.displayName)}</span>
        <div className="comment-body">
          <div className="comment-meta"><strong>{comment.displayName || 'Độc giả'}</strong><span>{formatDate(comment.createdAt)}</span></div>
          <p>{comment.content}</p>
        </div>
        {(account?.role === 'ADMIN' || account?.userId === comment.userId) && <button className="comment-delete" onClick={() => remove(comment.id)} aria-label="Xoá bình luận"><X size={13} /></button>}
      </li>)}
    </ul>}
  </div>
}
function Reader({ chapter, content, error, onClose, onTopup, onPrev, onNext, canPrev, canNext }) { return <div className="reader-overlay"><div className="reader-top"><button onClick={onClose}><X size={19} /> Đóng trình đọc</button><span>TÀ LỤA TRUYỆN</span><div><button onClick={onPrev} aria-label="Chương trước" disabled={!canPrev}><ChevronLeft size={19} /></button><button onClick={onNext} aria-label="Chương sau" disabled={!canNext}><ChevronRight size={19} /></button></div></div><article className="reader-page"><p className="eyebrow">{chapter.title || `Chương ${chapter.chapterNumber}`}</p><h1>{chapter.title || `Chương ${chapter.chapterNumber}`}</h1><div className="reader-rule" />{error ? <div className="paywall"><h2>Chương này cần Silver</h2><p>{error}</p><button className="primary-button" onClick={onTopup}>Nạp Silver</button></div> : <div className="reader-content">{content ? content.split('\n').map((paragraph, index) => <p key={index}>{paragraph}</p>) : <div className="loading-line">Đang mở trang sách...</div>}</div>}</article></div> }

const SILVER_PER_VND = 100 // 1 Silver = 100đ, giống tỉ lệ nạp Bạc mô tả trong đồ án
const money = (value) => Number(value || 0).toLocaleString('vi-VN')

function WalletPage({ account, setAccount, onBack }) {
  const [packages, setPackages] = useState([])
  const [isVip, setIsVip] = useState(account?.isVip === true)
  const [flow, setFlow] = useState(null) // { mode: 'topup' | 'vip', amount?, vipPackage? }
  const [notice, setNotice] = useState('')

  useEffect(() => {
    api.packages().then(items => setPackages(items.filter((item, index, list) => list.findIndex(candidate => candidate.id === item.id || candidate.name === item.name) === index))).catch(() => {})
    if (account) api.membershipMe().then(result => setIsVip(result.isVip === true)).catch(() => {})
  }, [account])

  const applyBalance = (delta, vipUnlocked) => {
    setAccount(current => {
      const updated = { ...current, silverBalance: Number(current.silverBalance || 0) + delta, ...(vipUnlocked ? { isVip: true } : {}) }
      localStorage.setItem('tailuatruyen_account', JSON.stringify(updated))
      return updated
    })
    if (vipUnlocked) setIsVip(true)
  }

  if (!account) return <main className="page"><Panel title="Ví Silver"><p>Bạn cần đăng nhập để nạp Silver.</p><a className="primary-button" href="#">Đăng nhập</a></Panel></main>

  return <main className="page">
    <button className="back-link" onClick={onBack}>← Trở về</button>
    <div className="wallet-hero">
      <div><p className="eyebrow"><Wallet size={14} /> Ví của bạn</p><h1>Quản lý số dư Bạc</h1></div>
      <div className="wallet-balance"><span>Số dư hiện tại</span><strong>{money(account.silverBalance)} bạc</strong></div>
    </div>

    <Panel title="Nạp Bạc nhanh">
      <h2>Chọn mệnh giá nạp</h2>
      <TopupPicker onPick={(amount) => setFlow({ mode: 'topup', amount })} />
    </Panel>

    <section className="vip-wallet-section">
      {!isVip && <div className="vip-cta-banner">
        <div><strong><Crown size={16} style={{ verticalAlign: '-3px', marginRight: 6 }} />Nâng cấp Hội viên VIP</strong><p>Đọc 100% truyện, không cần trả Bạc theo từng chương.</p></div>
        <button onClick={() => setFlow({ mode: 'vip' })}>Chọn gói đăng ký</button>
      </div>}
      <div className="section-heading"><div><p className="eyebrow">Hội viên</p><h2>{isVip ? 'Bạn đang là VIP' : 'Các gói Hội viên'}</h2></div></div>
      <p className="muted">VIP giúp bạn đọc mọi chương cần Silver mà không phải thanh toán từng chương.</p>
      <div className="vip-package-grid">{packages.map(vipPackage => <article className="vip-package" key={vipPackage.id}>
        <h3>{vipPackage.name}</h3>
        <p>{vipPackage.durationMonths} tháng · Đọc 100% truyện</p>
        <strong>{money(vipPackage.priceInSilver)} bạc</strong>
        <button className="primary-button" onClick={() => setFlow({ mode: 'vip', vipPackage })} disabled={isVip}>{isVip ? 'Đang hoạt động' : 'Đăng ký gói'}</button>
      </article>)}</div>
    </section>

    {notice && <p className="success-text" style={{ marginTop: 20 }}>{notice}</p>}

    {flow && <PurchaseFlowModal
      mode={flow.mode}
      account={account}
      packages={packages}
      initialAmount={flow.amount}
      initialPackage={flow.vipPackage}
      onClose={() => setFlow(null)}
      onTopupDone={(amount) => { applyBalance(amount, false); setNotice(`Nạp thành công ${money(amount)} Bạc. Số dư đã được cập nhật.`) }}
      onVipDone={(vipPackage) => { applyBalance(-vipPackage.priceInSilver, true); setNotice(`Đăng ký ${vipPackage.name} thành công! Bạn được đọc không giới hạn trong thời hạn gói.`) }}
    />}
  </main>
}

function TopupPicker({ onPick }) {
  const [amount, setAmount] = useState(50000)
  const presets = [50000, 100000, 500000]
  return <>
    <div className="wallet-options">{presets.map(value => <button key={value} className={amount === value ? 'selected' : ''} onClick={() => setAmount(value)}>{money(value)} bạc</button>)}</div>
    <button className="primary-button" onClick={() => onPick(amount)}><Plus size={16} /> Nạp {money(amount)} Bạc ngay</button>
  </>
}

/* ===================== Luồng mua gói / nạp Bạc: chọn gói -> xác nhận -> QR thanh toán -> hoàn tất ===================== */
function PurchaseFlowModal({ mode, account, packages, initialAmount, initialPackage, onClose, onTopupDone, onVipDone }) {
  const durations = useMemo(() => [...new Set(packages.map(p => p.durationMonths))].sort((a, b) => a - b), [packages])
  const [step, setStep] = useState(mode === 'vip' && !initialPackage ? 'select' : 'confirm')
  const [activeDuration, setActiveDuration] = useState(initialPackage?.durationMonths || durations[0])
  const [selectedPackage, setSelectedPackage] = useState(initialPackage || packages.find(p => p.durationMonths === (initialPackage?.durationMonths || durations[0])) || packages[0])
  const [amount, setAmount] = useState(initialAmount || 0)
  const [transaction, setTransaction] = useState(null)
  const [secondsLeft, setSecondsLeft] = useState(0)
  const [error, setError] = useState('')
  const [busy, setBusy] = useState(false)

  const balance = Number(account.silverBalance || 0)
  const price = mode === 'vip' ? Number(selectedPackage?.priceInSilver || 0) : amount
  const shortfall = mode === 'vip' ? Math.max(0, price - balance) : amount
  const topupAmount = mode === 'vip' ? shortfall : amount

  useEffect(() => {
    if (step !== 'qr' || !transaction?.expiredAt) return undefined
    const tick = () => {
      const diff = Math.max(0, Math.floor((new Date(transaction.expiredAt).getTime() - Date.now()) / 1000))
      setSecondsLeft(diff)
    }
    tick()
    const timer = setInterval(tick, 1000)
    return () => clearInterval(timer)
  }, [step, transaction])

  useEffect(() => {
    if (step !== 'qr' || !transaction?.transactionId) return undefined
    let alive = true
    const poll = setInterval(() => {
      api.transactionStatus(transaction.transactionId).then(result => {
        if (alive && result.status === 'SUCCESS') finishAfterPayment()
      }).catch(() => {})
    }, 4000)
    return () => { alive = false; clearInterval(poll) }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [step, transaction])

  const expiryLabel = useMemo(() => {
    if (mode !== 'vip' || !selectedPackage) return ''
    const date = new Date()
    date.setMonth(date.getMonth() + Number(selectedPackage.durationMonths || 0))
    return date.toLocaleDateString('vi-VN')
  }, [mode, selectedPackage])

  const formatTimer = (total) => `${String(Math.floor(total / 60)).padStart(2, '0')}:${String(total % 60).padStart(2, '0')}`

  const startPayment = async () => {
    setError('')
    setBusy(true)
    try {
      // BUG cũ: khi mua VIP, luôn nạp đúng bằng giá gói (kể cả khi đã đủ/gần đủ Bạc) thay vì phần còn THIẾU,
      // khiến số Bạc bị cộng/trừ sai lệch. Sửa: chỉ nạp phần thiếu (shortfall).
      const amountToPay = mode === 'vip' ? shortfall : topupAmount
      if (amountToPay <= 0) {
        await confirmDirectPurchase()
        return
      }
      const result = await api.topup(amountToPay)
      setTransaction(result)
      setStep('qr')
    } catch (requestError) {
      setError(requestError.message)
    } finally {
      setBusy(false)
    }
  }

  const finishAfterPayment = async () => {
    setBusy(true)
    setError('')
    try {
      if (mode === 'vip') {
        const result = await api.purchaseMembership(selectedPackage.id)
        onVipDone(selectedPackage, result)
      } else {
        onTopupDone(amount)
      }
      setStep('success')
    } catch (requestError) {
      setError(requestError.message)
    } finally {
      setBusy(false)
    }
  }

  const demoConfirmPayment = async () => {
    if (!transaction?.transactionId) return
    setBusy(true)
    setError('')
    try {
      await api.confirmTopup(transaction.transactionId)
      await finishAfterPayment()
    } catch (requestError) {
      setError(requestError.message)
      setBusy(false)
    }
  }

  const confirmDirectPurchase = async () => {
    setBusy(true)
    setError('')
    try {
      const result = await api.purchaseMembership(selectedPackage.id)
      onVipDone(selectedPackage, result)
      setStep('success')
    } catch (requestError) {
      setError(requestError.message)
    } finally {
      setBusy(false)
    }
  }

  const packagesForDuration = packages.filter(p => p.durationMonths === activeDuration)

  return <div className="purchase-modal-backdrop" onMouseDown={onClose}>
    <div className="purchase-modal" onMouseDown={(event) => event.stopPropagation()}>
      <div className="purchase-modal-head">
        <h2>{step === 'select' ? 'Chọn gói đăng ký' : step === 'confirm' ? (mode === 'vip' ? 'Xác nhận mua gói' : 'Nạp Bạc') : step === 'qr' ? 'Thanh toán qua ngân hàng' : 'Hoàn tất'}</h2>
        <button className="purchase-modal-close" onClick={onClose}><X size={16} /></button>
      </div>
      <div className="purchase-modal-body">
        {error && <p className="error-text">{error}</p>}

        {step === 'select' && <>
          <div className="balance-row"><span>Số dư hiện tại:</span><strong>{money(balance)} bạc</strong></div>
          {durations.length > 1 && <div className="duration-tabs">
            {durations.map(duration => <button key={duration} className={activeDuration === duration ? 'active' : ''} onClick={() => { setActiveDuration(duration); const first = packages.find(p => p.durationMonths === duration); if (first) setSelectedPackage(first) }}>{duration} tháng</button>)}
          </div>}
          <div className="package-option-list">
            {packagesForDuration.map(vipPackage => <button key={vipPackage.id} className={`package-option ${selectedPackage?.id === vipPackage.id ? 'selected' : ''}`} onClick={() => setSelectedPackage(vipPackage)}>
              <div>
                <div className="package-option-name"><ShieldCheck size={15} /> {vipPackage.name}<span className="package-tag">{vipPackage.durationMonths} tháng</span></div>
                <span className="package-feature"><CheckCircle2 size={12} /> Đọc 100.00% truyện</span>
              </div>
              <div className="package-price"><strong>{money(vipPackage.priceInSilver)} bạc</strong><span>({money(vipPackage.priceInSilver * SILVER_PER_VND)}đ) /{vipPackage.durationMonths} tháng</span></div>
            </button>)}
          </div>
        </>}

        {step === 'confirm' && mode === 'vip' && selectedPackage && <>
          <div className="confirm-summary">
            <div className="confirm-summary-tag"><span className="badge-new">Mua mới</span><strong>{selectedPackage.name} — {selectedPackage.durationMonths} tháng</strong></div>
            <div className="confirm-row"><span>Giá gói:</span><strong>{money(selectedPackage.priceInSilver)} bạc</strong></div>
            <div className="confirm-row accent"><span>Hết hạn sau khi mua:</span><strong>{expiryLabel}</strong></div>
            <div className="confirm-row"><span>Số dư hiện tại:</span><strong>{money(balance)} bạc</strong></div>
            {shortfall > 0 && <div className="confirm-row danger"><span>Thiếu:</span><strong>{money(shortfall)} bạc</strong></div>}
          </div>
          {shortfall > 0 ? <>
            <div className="topup-box"><span className="icon-plus"><Plus size={16} /></span><div><strong>Nạp tiền để mua gói</strong><p>Cần nạp thêm {money(shortfall)} bạc — Nạp tối thiểu {money(shortfall * SILVER_PER_VND)}đ ({money(shortfall)} bạc)</p></div></div>
            <div className="total-row"><span>Tổng thanh toán</span><strong>{money(shortfall * SILVER_PER_VND)}đ</strong></div>
          </> : <p className="muted">Bạn đã đủ Bạc để đăng ký gói này ngay.</p>}
        </>}

        {step === 'confirm' && mode === 'topup' && <>
          <div className="confirm-summary">
            <div className="confirm-summary-tag"><strong>Nạp {money(amount)} Bạc</strong></div>
            <div className="confirm-row"><span>Số dư hiện tại:</span><strong>{money(balance)} bạc</strong></div>
          </div>
          <div className="total-row"><span>Tổng thanh toán</span><strong>{money(amount * SILVER_PER_VND)}đ</strong></div>
        </>}

        {step === 'qr' && transaction && <>
          <div className="qr-timer"><span><Clock3 size={13} style={{ verticalAlign: '-2px', marginRight: 6 }} />Hết hạn sau</span><strong>{formatTimer(secondsLeft)}</strong></div>
          <div className="qr-box">
            {transaction.qrCodeUrl ? <img src={transaction.qrCodeUrl} alt="Mã QR thanh toán" /> : <div className="qr-fallback"><QrCode size={64} /></div>}
            <p className="qr-hint">Quét mã QR bằng app ngân hàng</p>
            <div className="qr-status"><span className="dot" /> Đang tự động kiểm tra giao dịch...</div>
          </div>
          <button className="demo-confirm-button" onClick={demoConfirmPayment} disabled={busy}>{busy ? 'Đang xác nhận...' : 'Tôi đã thanh toán (Demo)'}</button>
        </>}

        {step === 'success' && <div className="success-step">
          <div className="success-icon"><CheckCircle2 size={30} /></div>
          <h3>{mode === 'vip' ? 'Đăng ký VIP thành công!' : 'Nạp Bạc thành công!'}</h3>
          <p>{mode === 'vip' ? 'Bạn có thể đọc mọi chương trả phí trong thời hạn gói.' : 'Số dư của bạn đã được cập nhật.'}</p>
        </div>}
      </div>

      {step === 'select' && <div className="purchase-modal-footer">
        <button className="btn-neutral" onClick={onClose}>Đóng</button>
        <button className="primary-button" disabled={!selectedPackage} onClick={() => setStep('confirm')}>Chọn gói để mua</button>
      </div>}

      {step === 'confirm' && <div className="purchase-modal-footer">
        {mode === 'vip' && <button className="btn-neutral" onClick={() => setStep(packages.length > 1 || durations.length > 1 ? 'select' : 'confirm')}>← Quay lại</button>}
        {mode === 'vip' ? (
          shortfall > 0 ? (
            <button className="btn-bank-pay" disabled={busy} onClick={startPayment}><QrCode size={16} /> {busy ? 'Đang tạo mã...' : 'Thanh toán qua ngân hàng'}</button>
          ) : (
            <button className="primary-button" disabled={busy} onClick={startPayment}>{busy ? 'Đang xử lý...' : 'Xác nhận đăng ký gói'}</button>
          )
        ) : shortfall > 0 ? (
          <button className="btn-bank-pay" disabled={busy} onClick={startPayment}><QrCode size={16} /> {busy ? 'Đang tạo mã...' : 'Thanh toán qua ngân hàng'}</button>
        ) : (
          <button className="primary-button" disabled={busy} onClick={startPayment}>{busy ? 'Đang xử lý...' : 'Thanh toán qua ngân hàng'}</button>
        )}
      </div>}

      {step === 'qr' && <div className="purchase-modal-footer">
        <button className="btn-neutral" onClick={() => setStep('confirm')}>← Quay lại</button>
        <button className="btn-danger" onClick={onClose}>Đóng</button>
      </div>}

      {step === 'success' && <div className="purchase-modal-footer">
        <button className="primary-button" onClick={onClose}><CheckCircle2 size={16} /> Đóng</button>
      </div>}
    </div>
  </div>
}
function LoginModal({ onClose, onSubmit, loading, googleClientId }) {
  useEffect(() => {
    if (!googleClientId || !window.google?.accounts?.id) return
    const target = document.getElementById('google-signin-button')
    if (!target) return
    target.innerHTML = ''
    window.google.accounts.id.renderButton(target, {
      theme: 'outline',
      size: 'large',
      width: 320,
      text: 'continue_with',
      shape: 'pill'
    })
  }, [googleClientId])

  return <div className="modal-backdrop" onMouseDown={onClose}><div className="login-modal" onMouseDown={(event) => event.stopPropagation()}><button className="modal-close" onClick={onClose}><X size={18} /></button><span className="modal-icon"><Gem size={21} /></span><p className="eyebrow">Góc đọc riêng của bạn</p><h2>Đăng nhập để<br /><em>giữ lại hành trình.</em></h2><p className="modal-copy">Lưu truyện, theo dõi chương mới và nhận thêm những gợi ý hợp gu.</p>{googleClientId && <div id="google-signin-button" style={{ marginBottom: 16 }} />}{!googleClientId && <p className="muted">Thiếu VITE_GOOGLE_CLIENT_ID để bật Google Sign-In.</p>}<form onSubmit={onSubmit}><label>Email<input name="email" type="email" placeholder="ban@example.com" required /></label><label>Tên hiển thị<input name="displayName" placeholder="Bạn muốn được gọi là..." /></label><button className="primary-button" disabled={loading}>{loading ? 'Đang kết nối...' : 'Vào thư viện'} <ArrowRight size={17} /></button></form><small className="demo-note">Đăng nhập bằng Google hoặc tài khoản dev đã được cấp.</small></div></div> }

function AdminShell({ account, onLogout, toast }) {
  const [section, setSection] = useState(window.location.hash.split('/')[2] || 'tong-quan')
  const [stats, setStats] = useState({})
  const [users, setUsers] = useState([])
  const [stories, setStories] = useState([])
  const [transactions, setTransactions] = useState([])
  const [sources, setSources] = useState([])
  const [logs, setLogs] = useState([])
  const [notice, setNotice] = useState(toast)
  const [showAddStory, setShowAddStory] = useState(false)
  const [showAddChapter, setShowAddChapter] = useState(false)
  const [showAddSource, setShowAddSource] = useState(false)
  const [editingStoryId, setEditingStoryId] = useState(null)
  const [editingStory, setEditingStory] = useState({ title: '', author: '', description: '', coverImage: '' })
  const [storySearch, setStorySearch] = useState('')
  const [storySort, setStorySort] = useState('newest')
  const [chapterEditorStoryId, setChapterEditorStoryId] = useState(null)
  const [chapterEditor, setChapterEditor] = useState([])
  const refresh = () => {
    api.adminStats().then(setStats).catch(error => setNotice(error.message))
    api.adminUsers().then(data => setUsers(data.content || [])).catch(error => setNotice(error.message))
    api.adminStories()
      .then(data => setStories(Array.isArray(data) ? data : data.content || []))
      .catch(error => setNotice(`Không thể tải danh sách truyện: ${error.message}`))
    api.adminTransactions().then(data => setTransactions(data.content || [])).catch(error => setNotice(error.message))
    api.crawlerSources().then(setSources).catch(error => setNotice(error.message))
    api.crawlerLogs().then(setLogs).catch(error => setNotice(error.message))
  }
  useEffect(() => { refresh(); const onHash = () => setSection(window.location.hash.split('/')[2] || 'tong-quan'); window.addEventListener('hashchange', onHash); return () => window.removeEventListener('hashchange', onHash) }, [])
  const action = (request, text) => request.then(() => { setNotice(text); refresh() }).catch(error => setNotice(error.message))
  const startEditStory = (story) => {
    setEditingStoryId(story.id)
    setEditingStory({
      title: story.title || '',
      author: story.author || '',
      description: story.description || '',
      coverImage: story.coverImage || ''
    })
  }
  const cancelEditStory = () => {
    setEditingStoryId(null)
    setEditingStory({ title: '', author: '', description: '', coverImage: '' })
  }
  const saveEditStory = async (storyId) => {
    try {
      await api.updateStory(storyId, editingStory)
      setEditingStoryId(null)
      setEditingStory({ title: '', author: '', description: '', coverImage: '' })
      refresh()
      setNotice('Đã cập nhật truyện.')
    } catch (error) {
      setNotice(error.message || 'Không thể cập nhật truyện.')
    }
  }
  const filteredStories = useMemo(() => {
    const query = normalizeVN(storySearch.trim())
    const cloned = [...stories]
    const filtered = cloned.filter((story) => {
      if (!query) return true
      const haystack = normalizeVN(`${story.title || ''} ${story.author || ''} ${story.status || ''}`)
      return haystack.includes(query)
    })
    filtered.sort((a, b) => {
      switch (storySort) {
        case 'title':
          return (a.title || '').localeCompare(b.title || '')
        case 'status':
          return String(a.status || '').localeCompare(String(b.status || ''))
        case 'oldest':
          return Number(a.id || 0) - Number(b.id || 0)
        case 'newest':
        default:
          return Number(b.id || 0) - Number(a.id || 0)
      }
    })
    return filtered
  }, [storySearch, storySort, stories])
  const openChapterEditor = async (storyId) => {
    const nextStoryId = chapterEditorStoryId === storyId ? null : storyId
    setChapterEditorStoryId(nextStoryId)
    if (nextStoryId === null) {
      setChapterEditor([])
      return
    }
    try {
      const data = await api.adminChapters(storyId)
      setChapterEditor(data?.content || data || [])
    } catch {
      setChapterEditor([])
    }
  }
  const updateChapterDraft = (chapterId, field, value) => {
    setChapterEditor((current) => current.map((chapter) => chapter.id === chapterId ? { ...chapter, [field]: value } : chapter))
  }
  const saveChapterDraft = async (chapterId, storyId) => {
    const chapter = chapterEditor.find((item) => item.id === chapterId)
    if (!chapter) return
    try {
      await api.updateChapter(chapterId, {
        chapterNumber: Number(chapter.chapterNumber || 1),
        title: chapter.title || `Chương ${chapter.chapterNumber || 1}`,
        content: chapter.content || ''
      })
      setNotice('Đã cập nhật nội dung chương.')
      await openChapterEditor(storyId)
    } catch (error) {
      setNotice(error.message || 'Không thể cập nhật chương.')
    }
  }
  const links = [['tong-quan', 'Tổng quan'], ['nguoi-dung', 'Người dùng'], ['truyen', 'Truyện'], ['giao-dich', 'Giao dịch'], ['crawler', 'Crawler']]
  const userById = Object.fromEntries(users.map(user => [user.id, user]))
  const transactionType = { TOPUP: 'Nạp Silver', BUY_VIP: 'Mua VIP', BUY_CHAPTER: 'Mở chương' }
  return <div className="admin-shell"><aside className="admin-sidebar"><button className="brand" onClick={() => { window.location.hash = '/'; }}><span className="brand-mark">T</span><strong>QUẢN TRỊ</strong></button>{links.map(([key, label]) => <a className={section === key ? 'active' : ''} href={`#/admin/${key}`} key={key}>{label}</a>)}<button className="text-button" onClick={onLogout}>Đăng xuất</button></aside><section className="admin-main"><div className="admin-heading"><div><p className="eyebrow">Xin chào, {account.displayName || account.email}</p><h1>{links.find(item => item[0] === section)?.[1] || 'Quản trị'}</h1></div><button className="primary-button" onClick={refresh}>Làm mới dữ liệu</button></div>{notice && <div className="notice">{notice}</div>}{section === 'tong-quan' && <div className="stats-grid">{Object.entries(stats).map(([key, value]) => <Panel key={key} title={key}><strong>{String(value)}</strong></Panel>)}</div>}{section === 'nguoi-dung' && <AdminTable headers={['Email', 'Tên', 'Role', 'Silver', 'Trạng thái', 'Thao tác']} rows={users} render={user => <><td>{user.email}</td><td>{user.displayName}</td><td><select value={user.role} onChange={event => action(api.changeUserRole(user.id, event.target.value), 'Đã đổi role') }><option>MEMBER</option><option>VIP_MEMBER</option><option>ADMIN</option><option>GUEST</option></select></td><td>{(user.silverBalance || 0).toLocaleString('vi-VN')}</td><td>{user.locked ? 'Đã khóa' : 'Hoạt động'}</td><td><button onClick={() => action(api.toggleUserLock(user.id), 'Đã cập nhật trạng thái')}>{user.locked ? 'Mở khóa' : 'Khóa'}</button></td></>} />}
  {section === 'truyen' && <>
    <div className="admin-toolbar">
      <button className="outline-button-sm" onClick={() => { setShowAddStory(v => !v); setShowAddChapter(false) }}><Plus size={14} /> {showAddStory ? 'Đóng' : 'Thêm truyện mới'}</button>
      <button className="outline-button-sm" onClick={() => { setShowAddChapter(v => !v); setShowAddStory(false) }}><Plus size={14} /> {showAddChapter ? 'Đóng' : 'Thêm chương mới'}</button>
    </div>
    {showAddStory && <AddStoryForm onCreated={() => { setShowAddStory(false); action(Promise.resolve(), 'Đã thêm truyện mới') }} />}
    {showAddChapter && <AddChapterForm stories={stories} onCreated={() => { setShowAddChapter(false); action(Promise.resolve(), 'Đã thêm chương mới') }} />}
    <div className="admin-toolbar" style={{ marginBottom: 12 }}>
      <input value={storySearch} onChange={(event) => setStorySearch(event.target.value)} placeholder="Tìm truyện theo tên / tác giả / trạng thái" style={{ minWidth: 260 }} />
      <select value={storySort} onChange={(event) => setStorySort(event.target.value)}>
        <option value="newest">Mới nhất</option>
        <option value="oldest">Cũ nhất</option>
        <option value="title">Tên A–Z</option>
        <option value="status">Trạng thái</option>
      </select>
    </div>
    <AdminTable headers={['Tên truyện', 'Tác giả', 'Trạng thái', 'Thao tác']} rows={filteredStories} render={story => editingStoryId === story.id ? <>
      <td>
        <input value={editingStory.title} onChange={(event) => setEditingStory(current => ({ ...current, title: event.target.value }))} placeholder="Tên truyện" style={{ marginBottom: 6, width: '100%' }} />
        {/* BUG cũ: form sửa chỉ có ô Tên/Tác giả, thiếu hẳn ô Ảnh bìa và Mô tả nên không sửa được dù state đã có sẵn dữ liệu */}
        <input value={editingStory.coverImage} onChange={(event) => setEditingStory(current => ({ ...current, coverImage: event.target.value }))} placeholder="Link ảnh bìa (coverImage)" style={{ marginBottom: 6, width: '100%' }} />
        {editingStory.coverImage && <img src={editingStory.coverImage} alt="Xem trước ảnh bìa" style={{ width: 60, height: 84, objectFit: 'cover', borderRadius: 6, marginBottom: 6 }} />}
        <textarea value={editingStory.description} onChange={(event) => setEditingStory(current => ({ ...current, description: event.target.value }))} placeholder="Mô tả truyện" rows={3} style={{ width: '100%' }} />
      </td>
      <td><input value={editingStory.author} onChange={(event) => setEditingStory(current => ({ ...current, author: event.target.value }))} placeholder="Tác giả" /></td>
      <td>{story.status}</td>
      <td>
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
          <button onClick={() => saveEditStory(story.id)}>Lưu</button>
          <button onClick={cancelEditStory}>Huỷ</button>
        </div>
      </td>
    </> : <>
      <td>{story.title}</td>
      <td>{story.author}</td>
      <td>{story.status}</td>
      <td>
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
          <button onClick={() => startEditStory(story)}>Sửa</button>
          <button onClick={() => { const next = window.confirm(`Bạn chắc chắn muốn xoá hẳn truyện "${story.title}" khỏi database không?`); if (next) action(api.deleteStory(story.id), 'Đã xoá truyện khỏi database.') }} className="btn-danger">Xoá</button>
          <button onClick={() => action(api.toggleStory(story.id), story.status === 'ACTIVE' ? 'Đã ẩn truyện' : 'Đã hiển thị truyện')}>{story.status === 'ACTIVE' ? 'Ẩn' : 'Hiện'}</button>
          <button onClick={() => action(api.restoreStory(story.id), 'Đã khôi phục truyện')}>Khôi phục</button>
          <button onClick={() => openChapterEditor(story.id)}>{chapterEditorStoryId === story.id ? 'Đóng chương' : 'Sửa chương'}</button>
        </div>
      </td>
    </>} />
    {chapterEditorStoryId && <div className="admin-form" style={{ marginTop: 12 }}>
      <h3>Chỉnh sửa chương</h3>
      {chapterEditor.length === 0 ? <p className="muted">Chưa có chương trong truyện này.</p> : chapterEditor.map((chapter) => <div key={chapter.id} style={{ border: '1px solid #dfe3ea', borderRadius: 12, padding: 12, marginBottom: 12 }}>
        <div style={{ display: 'grid', gridTemplateColumns: '120px 1fr', gap: 10, marginBottom: 8 }}>
          <label>Chương số<input type="number" value={chapter.chapterNumber || ''} onChange={(event) => updateChapterDraft(chapter.id, 'chapterNumber', event.target.value)} /></label>
          <label>Tiêu đề<input value={chapter.title || ''} onChange={(event) => updateChapterDraft(chapter.id, 'title', event.target.value)} /></label>
        </div>
        <label style={{ display: 'block', marginBottom: 8 }}>Nội dung</label>
        <textarea rows={8} value={chapter.content || ''} onChange={(event) => updateChapterDraft(chapter.id, 'content', event.target.value)} style={{ width: '100%' }} />
        <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: 8 }}><button onClick={() => saveChapterDraft(chapter.id, chapterEditorStoryId)}>Lưu chương</button></div>
      </div>)}
    </div>}
  </>}
  {section === 'giao-dich' && <AdminTable headers={['ID', 'Người dùng', 'Loại', 'Silver', 'Trạng thái', 'Thời gian']} rows={transactions} render={item => <><td>{item.id}</td><td>{item.user?.email || userById[item.userId]?.email || item.userId || '—'}</td><td>{transactionType[item.type] || item.type}</td><td>{Number(item.amount || 0).toLocaleString('vi-VN')}</td><td>{item.status}</td><td>{item.createdAt ? new Date(item.createdAt).toLocaleString('vi-VN') : '—'}</td></>} />}
  {section === 'crawler' && <>
    <div className="admin-toolbar">
      <button className="primary-button" onClick={() => action(api.runCrawler(), 'Đã bắt đầu crawl')}>Chạy tất cả nguồn bật</button>
      <button className="outline-button-sm" onClick={() => setShowAddSource(v => !v)}><Plus size={14} /> {showAddSource ? 'Đóng' : 'Thêm nguồn crawl'}</button>
    </div>
    {showAddSource && <AddCrawlerSourceForm onCreated={() => { setShowAddSource(false); action(Promise.resolve(), 'Đã thêm nguồn crawl') }} />}
    <AdminTable headers={['Nguồn', 'URL', 'Trạng thái', 'Thao tác']} rows={sources} render={source => <><td>{source.name}</td><td>{source.baseUrl}</td><td>{source.active ? 'Bật' : 'Tắt'}</td><td><button onClick={() => action(api.toggleCrawlerSource(source.id), 'Đã cập nhật nguồn')}>Bật/tắt</button><button onClick={() => action(api.runCrawler(source.id), 'Đã bắt đầu crawl')}>Chạy</button></td></>} />
    <h2>Nhật ký crawl</h2>
    <AdminTable headers={['Trạng thái', 'Thông báo']} rows={logs} render={log => <><td>{log.status}</td><td>{log.message}</td></>} />
  </>}
  </section></div>
}

function AddStoryForm({ onCreated }) {
  const [values, setValues] = useState({ title: '', author: '', description: '', coverImage: '' })
  const [error, setError] = useState('')
  const [busy, setBusy] = useState(false)
  const set = (key) => (event) => setValues(current => ({ ...current, [key]: event.target.value }))
  const submit = async (event) => {
    event.preventDefault()
    setError(''); setBusy(true)
    try {
      await api.createStory(values)
      setValues({ title: '', author: '', description: '', coverImage: '' })
      onCreated()
    } catch (requestError) {
      setError(requestError.message)
    } finally {
      setBusy(false)
    }
  }
  return <form className="admin-form admin-inline-form" onSubmit={submit}>
    <div className="admin-form-grid">
      <input placeholder="Tên truyện" value={values.title} onChange={set('title')} required />
      <input placeholder="Tác giả" value={values.author} onChange={set('author')} />
      <input placeholder="Link ảnh bìa (coverImage)" value={values.coverImage} onChange={set('coverImage')} />
    </div>
    <textarea placeholder="Mô tả truyện" rows={3} value={values.description} onChange={set('description')} />
    {error && <p className="error-text">{error}</p>}
    <button className="primary-button" disabled={busy}>{busy ? 'Đang lưu...' : 'Lưu truyện mới'}</button>
  </form>
}

function AddChapterForm({ stories, onCreated }) {
  const [storyId, setStoryId] = useState(stories[0]?.id || '')
  const [values, setValues] = useState({ chapterNumber: 1, title: '', content: '' })
  const [error, setError] = useState('')
  const [busy, setBusy] = useState(false)
  const set = (key) => (event) => setValues(current => ({ ...current, [key]: event.target.value }))
  const submit = async (event) => {
    event.preventDefault()
    if (!storyId) { setError('Vui lòng chọn truyện.'); return }
    setError(''); setBusy(true)
    try {
      await api.createChapter(storyId, { ...values, chapterNumber: Number(values.chapterNumber) })
      setValues({ chapterNumber: Number(values.chapterNumber) + 1, title: '', content: '' })
      onCreated()
    } catch (requestError) {
      setError(requestError.message)
    } finally {
      setBusy(false)
    }
  }
  return <form className="admin-form admin-inline-form" onSubmit={submit}>
    <div className="admin-form-grid">
      <select value={storyId} onChange={(event) => setStoryId(event.target.value)}>
        {stories.map(story => <option key={story.id} value={story.id}>{story.title}</option>)}
      </select>
      <input type="number" min="1" placeholder="Số chương" value={values.chapterNumber} onChange={set('chapterNumber')} required />
      <input placeholder="Tiêu đề chương" value={values.title} onChange={set('title')} required />
    </div>
    <textarea placeholder="Nội dung chương" rows={4} value={values.content} onChange={set('content')} required />
    {error && <p className="error-text">{error}</p>}
    <button className="primary-button" disabled={busy}>{busy ? 'Đang lưu...' : 'Lưu chương mới'}</button>
  </form>
}

function AddCrawlerSourceForm({ onCreated }) {
  const [values, setValues] = useState({ name: '', baseUrl: '', cronExpression: '0 0 * * * *', maxChapters: 20 })
  const [error, setError] = useState('')
  const [busy, setBusy] = useState(false)
  const set = (key) => (event) => setValues(current => ({ ...current, [key]: event.target.value }))
  const submit = async (event) => {
    event.preventDefault()
    setError(''); setBusy(true)
    try {
      await api.addCrawlerSource({ ...values, maxChapters: Number(values.maxChapters), active: true })
      setValues({ name: '', baseUrl: '', cronExpression: '0 0 * * * *', maxChapters: 20 })
      onCreated()
    } catch (requestError) {
      setError(requestError.message)
    } finally {
      setBusy(false)
    }
  }
  return <form className="admin-form admin-inline-form" onSubmit={submit}>
    <div className="admin-form-grid">
      <input placeholder="Tên nguồn" value={values.name} onChange={set('name')} required />
      <input placeholder="URL trang truyện cần crawl" value={values.baseUrl} onChange={set('baseUrl')} required />
      <input placeholder="Cron expression" value={values.cronExpression} onChange={set('cronExpression')} required />
      <input type="number" min="1" placeholder="Số chương tối đa / lần" value={values.maxChapters} onChange={set('maxChapters')} required />
    </div>
    {error && <p className="error-text">{error}</p>}
    <button className="primary-button" disabled={busy}>{busy ? 'Đang lưu...' : 'Lưu nguồn crawl'}</button>
  </form>
}

function AdminTable({ headers, rows, render }) { return <div className="table-wrap"><table><thead><tr>{headers.map(header => <th key={header}>{header}</th>)}</tr></thead><tbody>{rows.map((row, index) => <tr key={row.id || index}>{render(row)}</tr>)}</tbody></table>{!rows.length && <p className="muted">Chưa có dữ liệu.</p>}</div> }

export default App
