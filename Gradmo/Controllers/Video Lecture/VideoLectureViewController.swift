//
//  VideoLectureViewController.swift
//  Gradmo
//
//  Created by Philanderer on 12/04/26.
//

import UIKit

struct VideoLectureContent {
    let thumbnailImage: UIImage?
    let title: String
    let dateText: String
    let durationText: String
    let classTagText: String
    let contextTagText: String
    let descriptionText: String
}

class VideoLectureViewController: UIViewController {
    @IBOutlet weak var videoThumbnailImageView: UIImageView!
    @IBOutlet weak var glassView: UIView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var videoDateLabel: UILabel!
    @IBOutlet weak var videoDurationLabel: UILabel!
    @IBOutlet weak var videoClassTagLabel: UILabel!
    @IBOutlet weak var videoClassTagView: UIView!
    @IBOutlet weak var videoContextTagLabel: UILabel!
    @IBOutlet weak var videoContextTagView: UIView!
    @IBOutlet weak var videoDescriptionLabel: UILabel!

    var lectureContent: VideoLectureContent?
    var batchDetail: BatchDetailItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyGlassOverlayLayout()
    }

    @IBAction func backButtonTapped(_ sender: UIButton!){
        navigationController?.popViewController(animated: true)
    }

}

extension VideoLectureViewController {
    func setupUI() {
        view.backgroundColor = .white
        videoThumbnailImageView.layer.cornerRadius = 12
        videoThumbnailImageView.clipsToBounds = true
        videoThumbnailImageView.contentMode = .scaleAspectFill
        configureGlassOverlay()

        videoClassTagView.layer.cornerRadius = 7
        videoContextTagView.layer.cornerRadius = 7

        videoTitleLabel.font = UIFont.GilroyBold(ofSize: 24)
        videoDateLabel.font = UIFont.GilroyMedium(ofSize: 14)
        videoDurationLabel.font = UIFont.GilroyMedium(ofSize: 10)
        videoDescriptionLabel.font = UIFont.GilroyRegular(ofSize: 14)
        videoContextTagLabel.font = UIFont.GilroyRegular(ofSize: 10)
        videoClassTagLabel.font = UIFont.GilroyRegular(ofSize: 10)

        applyContent()
    }

    private func configureGlassOverlay() {
        glassView.backgroundColor = UIColor.white.withAlphaComponent(0.68)
        glassView.layer.borderWidth = 1.2
        glassView.layer.borderColor = UIColor.white.withAlphaComponent(0.82).cgColor
        glassView.layer.shadowColor = UIColor.black.withAlphaComponent(0.32).cgColor
        glassView.layer.shadowOpacity = 1
        glassView.layer.shadowRadius = 26
        glassView.layer.shadowOffset = CGSize(width: 0, height: 12)
        glassView.layer.masksToBounds = false

        if glassView.viewWithTag(6001) == nil {
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialLight))
            blurView.tag = 6001
            blurView.frame = glassView.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurView.isUserInteractionEnabled = false
            glassView.insertSubview(blurView, at: 0)
        }

        if glassView.viewWithTag(6002) == nil {
            let highlightView = UIView()
            highlightView.tag = 6002
            highlightView.isUserInteractionEnabled = false
            highlightView.backgroundColor = UIColor.white.withAlphaComponent(0.20)
            glassView.insertSubview(highlightView, aboveSubview: glassView.subviews[0])
        }

        if let playIcon = glassView.subviews.compactMap({ $0 as? UIImageView }).first {
            playIcon.tintColor = UIColor(red: 0.48, green: 0.30, blue: 0.14, alpha: 1)
            playIcon.alpha = 0.95
        }
    }

    private func applyGlassOverlayLayout() {
        glassView.layer.cornerRadius = glassView.bounds.height / 2
        glassView.layer.shadowPath = UIBezierPath(ovalIn: glassView.bounds).cgPath

        if let blurView = glassView.viewWithTag(6001) as? UIVisualEffectView {
            blurView.frame = glassView.bounds
            blurView.layer.cornerRadius = glassView.bounds.height / 2
            blurView.layer.masksToBounds = true
        }

        if let highlightView = glassView.viewWithTag(6002) {
            let inset = glassView.bounds.width * 0.10
            highlightView.frame = glassView.bounds.insetBy(dx: inset, dy: inset)
            highlightView.layer.cornerRadius = highlightView.bounds.height / 2
            highlightView.layer.masksToBounds = true
        }
    }

    private func applyContent() {
        let content = lectureContent ?? makeDefaultContent()

        videoThumbnailImageView.image = content.thumbnailImage ?? UIImage(named: "videoLectures")
        videoTitleLabel.text = content.title
        videoDateLabel.text = content.dateText
        videoDurationLabel.text = content.durationText
        videoClassTagLabel.text = paddedTagText(for: content.classTagText)
        videoContextTagLabel.text = paddedTagText(for: content.contextTagText)
        videoDescriptionLabel.text = content.descriptionText
    }

    private func makeDefaultContent() -> VideoLectureContent {
        let batchName = batchDetail?.batchName.nonEmpty ?? "UI/UX Fundamentals"
        let teacherName = batchDetail?.teacherName.nonEmpty ?? "Mentor Session"
        let grade = batchDetail?.grade.nonEmpty ?? "Class 12"
        let subject = batchDetail?.subject.nonEmpty ?? "Design"

        return VideoLectureContent(
            thumbnailImage: UIImage(named: "videoLectures"),
            title: batchName,
            dateText: "12 Apr 2026",
            durationText: "32 min",
            classTagText: grade,
            contextTagText: subject,
            descriptionText: "Watch this lecture to revise key concepts for \(subject.lowercased()) with \(teacherName). The session is organized in a simple step-by-step format so students can review the batch material anytime inside the app."
        )
    }

    private func paddedTagText(for value: String) -> String {
        "  \(value)  "
    }
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
