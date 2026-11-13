package TranDucTai.Tailuatruyen.service;

import TranDucTai.Tailuatruyen.dto.StoryRequest;
import TranDucTai.Tailuatruyen.entity.Story;
import TranDucTai.Tailuatruyen.entity.StatusEnum;
import TranDucTai.Tailuatruyen.exception.AppException;
import TranDucTai.Tailuatruyen.repository.ChapterRepository;
import TranDucTai.Tailuatruyen.repository.StoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.Normalizer;
import java.util.List;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Service
public class StoryService {

    @Autowired private StoryRepository storyRepository;
    @Autowired private ChapterRepository chapterRepository;

    private static final Pattern DIACRITICS = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");

    // Bỏ dấu tiếng Việt + hạ chữ thường, để tìm kiếm không phân biệt dấu
    // (VD: gõ "ta vu" hoặc "Tạ Vũ" đều tìm ra tác giả "Tạ Vũ")
    private static String normalize(String input) {
        if (input == null) return "";
        String temp = Normalizer.normalize(input, Normalizer.Form.NFD);
        temp = DIACRITICS.matcher(temp).replaceAll("");
        temp = temp.replace('đ', 'd').replace('Đ', 'D');
        return temp.toLowerCase();
    }

    // Giai đoạn 3: danh sách truyện ACTIVE cho trang chủ, có thể tìm theo TÊN TRUYỆN hoặc TÊN TÁC GIẢ
    // (BUG cũ: chỉ tìm theo title, không tìm theo author -> sửa lại tìm cả 2, không phân biệt dấu)
    public Page<Story> listActive(String search, Pageable pageable) {
        if (search == null || search.isBlank()) {
            return storyRepository.findByStatus(StatusEnum.ACTIVE, pageable);
        }

        String query = normalize(search.trim());
        List<Story> matched = storyRepository.findByStatus(StatusEnum.ACTIVE).stream()
                .filter(s -> normalize(s.getTitle()).contains(query) || normalize(s.getAuthor()).contains(query))
                .collect(Collectors.toList());

        int start = (int) Math.min(pageable.getOffset(), matched.size());
        int end = Math.min(start + pageable.getPageSize(), matched.size());
        return new PageImpl<>(matched.subList(start, end), pageable, matched.size());
    }

    public java.util.List<Story> listAll() {
        return storyRepository.findAllByOrderByIdAsc();
    }

    public Story getById(Long id) {
        return storyRepository.findById(id)
                .orElseThrow(() -> AppException.notFound("Không tìm thấy truyện!"));
    }

    public Story getPublicById(Long id) {
        Story story = getById(id);
        if (story.getStatus() != StatusEnum.ACTIVE) {
            throw AppException.notFound("Không tìm thấy truyện!");
        }
        return story;
    }

    public long countChapters(Long storyId) {
        return chapterRepository.countByStory(getById(storyId));
    }

    // Giai đoạn 8: Admin CRUD truyện thủ công (ngoài crawler)
    @Transactional
    public Story create(StoryRequest request) {
        Story story = Story.builder()
                .title(request.title())
                .author(request.author())
                .description(request.description())
                .coverImage(request.coverImage())
                .status(StatusEnum.ACTIVE)
                .build();
        return storyRepository.save(story);
    }

    @Transactional
    public Story update(Long id, StoryRequest request) {
        Story story = getById(id);
        story.setTitle(request.title());
        story.setAuthor(request.author());
        story.setDescription(request.description());
        story.setCoverImage(request.coverImage());
        return storyRepository.save(story);
    }

    // Ẩn/hiện truyện thay vì xoá cứng, để không mất dữ liệu chương/bình luận liên quan
    @Transactional
    public Story toggleVisibility(Long id) {
        Story story = getById(id);
        story.setStatus(story.getStatus() == StatusEnum.ACTIVE ? StatusEnum.INACTIVE : StatusEnum.ACTIVE);
        return storyRepository.save(story);
    }

    @Transactional
    public Story softDelete(Long id) {
        Story story = getById(id);
        story.setStatus(StatusEnum.INACTIVE);
        return storyRepository.save(story);
    }

    @Transactional
    public void deleteHard(Long id) {
        Story story = getById(id);
        storyRepository.delete(story);
    }

    @Transactional
    public Story restore(Long id) {
        Story story = getById(id);
        story.setStatus(StatusEnum.ACTIVE);
        return storyRepository.save(story);
    }
}
